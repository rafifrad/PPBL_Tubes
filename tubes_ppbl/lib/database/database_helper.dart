import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food.dart';
import '../models/equipment.dart';
import '../models/laundry.dart';
import '../models/expense.dart';
import '../models/bill.dart';
import '../models/finance_note.dart';
import '../models/daily_need.dart';
import '../models/shopping_list.dart';
import '../models/activity_reminder.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kost_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('DROP TABLE IF EXISTS persediaan_makanan');
          await db.execute('DROP TABLE IF EXISTS peralatan_kamar');
          await db.execute('DROP TABLE IF EXISTS laundry');
          await db.execute('DROP TABLE IF EXISTS pengeluaran_kos');
          await db.execute('DROP TABLE IF EXISTS tagihan_bulanan');
          await db.execute('DROP TABLE IF EXISTS catatan_keuangan');
          await _createDB(db, newVersion);
          return;
        }

        if (oldVersion < 4) {
          await _createFinanceTables(db);
        }

        if (oldVersion < 5) {
          await _createNewCRUDTables(db);
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabel Persediaan Makanan
    await db.execute('''
      CREATE TABLE persediaan_makanan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        purchaseDate TEXT NOT NULL
      )
    ''');

    // Tabel Peralatan Kamar
    await db.execute('''
      CREATE TABLE peralatan_kamar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        condition TEXT NOT NULL
      )
    ''');

    // Tabel Laundry
    await db.execute('''
      CREATE TABLE laundry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await _createFinanceTables(db);
    await _createNewCRUDTables(db);
  }

  Future<void> _createNewCRUDTables(Database db) async {
    // Tabel Kebutuhan Harian
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kebutuhan_harian (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');

    // Tabel Daftar Belanja
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daftar_belanja (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item TEXT NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');

    // Tabel Pengingat Kegiatan
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pengingat_kegiatan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        time TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createFinanceTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pengeluaran_kos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS tagihan_bulanan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        dueDate TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS catatan_keuangan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        note TEXT NOT NULL,
        amount REAL NOT NULL
      )
    ''');
  }

  // ========== CRUD PERSEDIAAN MAKANAN ==========
  Future<int> insertFood(Food food) async {
    final db = await database;
    return await db.insert('persediaan_makanan', food.toMap());
  }

  Future<List<Food>> getAllFoods() async {
    final db = await database;
    final result = await db.query('persediaan_makanan', orderBy: 'purchaseDate DESC');
    return result.map((map) => Food.fromMap(map)).toList();
  }

  Future<Food?> getFoodById(int id) async {
    final db = await database;
    final result = await db.query(
      'persediaan_makanan',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Food.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateFood(Food food) async {
    final db = await database;
    return await db.update(
      'persediaan_makanan',
      food.toMap(),
      where: 'id = ?',
      whereArgs: [food.id],
    );
  }

  Future<int> deleteFood(int id) async {
    final db = await database;
    return await db.delete(
      'persediaan_makanan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD PERALATAN KAMAR ==========
  Future<int> insertEquipment(Equipment equipment) async {
    final db = await database;
    return await db.insert('peralatan_kamar', equipment.toMap());
  }

  Future<List<Equipment>> getAllEquipments() async {
    final db = await database;
    final result = await db.query('peralatan_kamar', orderBy: 'name ASC');
    return result.map((map) => Equipment.fromMap(map)).toList();
  }

  Future<Equipment?> getEquipmentById(int id) async {
    final db = await database;
    final result = await db.query(
      'peralatan_kamar',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Equipment.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateEquipment(Equipment equipment) async {
    final db = await database;
    return await db.update(
      'peralatan_kamar',
      equipment.toMap(),
      where: 'id = ?',
      whereArgs: [equipment.id],
    );
  }

  Future<int> deleteEquipment(int id) async {
    final db = await database;
    return await db.delete(
      'peralatan_kamar',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD LAUNDRY ==========
  Future<int> insertLaundry(Laundry laundry) async {
    final db = await database;
    return await db.insert('laundry', laundry.toMap());
  }

  Future<List<Laundry>> getAllLaundries() async {
    final db = await database;
    final result = await db.query('laundry', orderBy: 'status ASC, type ASC');
    return result.map((map) => Laundry.fromMap(map)).toList();
  }

  Future<Laundry?> getLaundryById(int id) async {
    final db = await database;
    final result = await db.query(
      'laundry',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Laundry.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateLaundry(Laundry laundry) async {
    final db = await database;
    return await db.update(
      'laundry',
      laundry.toMap(),
      where: 'id = ?',
      whereArgs: [laundry.id],
    );
  }

  Future<int> deleteLaundry(int id) async {
    final db = await database;
    return await db.delete(
      'laundry',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD PENGELUARAN KOS ==========
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('pengeluaran_kos', expense.toMap());
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final result = await db.query(
      'pengeluaran_kos',
      orderBy: 'date DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'pengeluaran_kos',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'pengeluaran_kos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD TAGIHAN BULANAN ==========
  Future<int> insertBill(Bill bill) async {
    final db = await database;
    return await db.insert('tagihan_bulanan', bill.toMap());
  }

  Future<List<Bill>> getAllBills() async {
    final db = await database;
    final result = await db.query(
      'tagihan_bulanan',
      orderBy: 'dueDate ASC',
    );
    return result.map((map) => Bill.fromMap(map)).toList();
  }

  Future<int> updateBill(Bill bill) async {
    final db = await database;
    return await db.update(
      'tagihan_bulanan',
      bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<int> deleteBill(int id) async {
    final db = await database;
    return await db.delete(
      'tagihan_bulanan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD CATATAN KEUANGAN KECIL ==========
  Future<int> insertFinanceNote(FinanceNote note) async {
    final db = await database;
    return await db.insert('catatan_keuangan', note.toMap());
  }

  Future<List<FinanceNote>> getAllFinanceNotes() async {
    final db = await database;
    final result = await db.query(
      'catatan_keuangan',
      orderBy: 'id DESC',
    );
    return result.map((map) => FinanceNote.fromMap(map)).toList();
  }

  Future<int> updateFinanceNote(FinanceNote note) async {
    final db = await database;
    return await db.update(
      'catatan_keuangan',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteFinanceNote(int id) async {
    final db = await database;
    return await db.delete(
      'catatan_keuangan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD KEBUTUHAN HARIAN ==========
  Future<int> insertDailyNeed(DailyNeed dailyNeed) async {
    final db = await database;
    return await db.insert('kebutuhan_harian', dailyNeed.toMap());
  }

  Future<List<DailyNeed>> getAllDailyNeeds() async {
    final db = await database;
    final result = await db.query('kebutuhan_harian', orderBy: 'name ASC');
    return result.map((map) => DailyNeed.fromMap(map)).toList();
  }

  Future<DailyNeed?> getDailyNeedById(int id) async {
    final db = await database;
    final result = await db.query(
      'kebutuhan_harian',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return DailyNeed.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateDailyNeed(DailyNeed dailyNeed) async {
    final db = await database;
    return await db.update(
      'kebutuhan_harian',
      dailyNeed.toMap(),
      where: 'id = ?',
      whereArgs: [dailyNeed.id],
    );
  }

  Future<int> deleteDailyNeed(int id) async {
    final db = await database;
    return await db.delete(
      'kebutuhan_harian',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD DAFTAR BELANJA ==========
  Future<int> insertShoppingList(ShoppingList shoppingList) async {
    final db = await database;
    return await db.insert('daftar_belanja', shoppingList.toMap());
  }

  Future<List<ShoppingList>> getAllShoppingLists() async {
    final db = await database;
    final result = await db.query('daftar_belanja', orderBy: 'item ASC');
    return result.map((map) => ShoppingList.fromMap(map)).toList();
  }

  Future<ShoppingList?> getShoppingListById(int id) async {
    final db = await database;
    final result = await db.query(
      'daftar_belanja',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return ShoppingList.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateShoppingList(ShoppingList shoppingList) async {
    final db = await database;
    return await db.update(
      'daftar_belanja',
      shoppingList.toMap(),
      where: 'id = ?',
      whereArgs: [shoppingList.id],
    );
  }

  Future<int> deleteShoppingList(int id) async {
    final db = await database;
    return await db.delete(
      'daftar_belanja',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD PENGINGAT KEGIATAN ==========
  Future<int> insertActivityReminder(ActivityReminder reminder) async {
    final db = await database;
    return await db.insert('pengingat_kegiatan', reminder.toMap());
  }

  Future<List<ActivityReminder>> getAllActivityReminders() async {
    final db = await database;
    final result = await db.query('pengingat_kegiatan', orderBy: 'time ASC');
    return result.map((map) => ActivityReminder.fromMap(map)).toList();
  }

  Future<ActivityReminder?> getActivityReminderById(int id) async {
    final db = await database;
    final result = await db.query(
      'pengingat_kegiatan',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return ActivityReminder.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateActivityReminder(ActivityReminder reminder) async {
    final db = await database;
    return await db.update(
      'pengingat_kegiatan',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> deleteActivityReminder(int id) async {
    final db = await database;
    return await db.delete(
      'pengingat_kegiatan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

