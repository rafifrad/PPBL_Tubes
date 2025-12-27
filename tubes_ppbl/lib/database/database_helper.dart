import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async'; // Untuk StreamController
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
  
  // Stream untuk memberitahu UI jika ada perubahan data keuangan (saldo/catatan)
  final _transactionController = StreamController<void>.broadcast();
  Stream<void> get onTransactionChanged => _transactionController.stream;

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
      version: 9,  // Update ke versi 9 untuk kolom harga (price)
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        // ... (kode upgrade versi sebelumnya) ...
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

        if (oldVersion < 4) await _createFinanceTables(db);
        if (oldVersion < 5) await _createNewCRUDTables(db);
        if (oldVersion < 6) await db.execute('ALTER TABLE pengeluaran_kos ADD COLUMN description TEXT DEFAULT ""');
        if (oldVersion < 7) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS pemasukan (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              amount REAL NOT NULL,
              category TEXT NOT NULL,
              description TEXT DEFAULT '',
              date TEXT NOT NULL
            )
          ''');
        }

        if (oldVersion < 8) {
          await db.execute('CREATE TABLE IF NOT EXISTS balance (id INTEGER PRIMARY KEY, amount REAL NOT NULL)');
          await db.insert('balance', {'id': 1, 'amount': 0.0}, conflictAlgorithm: ConflictAlgorithm.ignore);
          try { await db.execute('ALTER TABLE catatan_keuangan ADD COLUMN type TEXT DEFAULT "expense"'); } catch (e) {}
          try { await db.execute('ALTER TABLE catatan_keuangan ADD COLUMN timestamp INTEGER DEFAULT 0'); } catch (e) {}
          try { await db.execute('ALTER TABLE catatan_keuangan ADD COLUMN source TEXT DEFAULT "manual"'); } catch (e) {}
          final now = DateTime.now().millisecondsSinceEpoch;
          await db.update('catatan_keuangan', {'timestamp': now}, where: 'timestamp = 0');
        }

        // --- MIKGRASI KE VERSI 9 (TAMBAH KOLOM HARGA) ---
        if (oldVersion < 9) {
          try { await db.execute('ALTER TABLE persediaan_makanan ADD COLUMN price REAL DEFAULT 0'); } catch (e) {}
          try { await db.execute('ALTER TABLE laundry ADD COLUMN price REAL DEFAULT 0'); } catch (e) {}
          try { await db.execute('ALTER TABLE kebutuhan_harian ADD COLUMN price REAL DEFAULT 0'); } catch (e) {}
          try { await db.execute('ALTER TABLE daftar_belanja ADD COLUMN price REAL DEFAULT 0'); } catch (e) {}
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE persediaan_makanan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        purchaseDate TEXT NOT NULL,
        price REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE peralatan_kamar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        condition TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE laundry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        status TEXT NOT NULL,
        price REAL DEFAULT 0
      )
    ''');

    await _createFinanceTables(db);
    await _createNewCRUDTables(db);
    
    // Inisialisasi saldo untuk database baru (Gunakan ignore agar tidak error jika id: 1 sudah ada)
    await db.insert('balance', {'id': 1, 'amount': 0.0}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> _createNewCRUDTables(Database db) async {
    // Tabel Kebutuhan Harian
    await db.execute('''
      CREATE TABLE IF NOT EXISTS kebutuhan_harian (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL DEFAULT 0
      )
    ''');

    // Tabel Daftar Belanja
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daftar_belanja (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL DEFAULT 0
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
        description TEXT DEFAULT '',
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

    // Versi baru tabel catatan_keuangan
    await db.execute('''
      CREATE TABLE IF NOT EXISTS catatan_keuangan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        note TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        source TEXT NOT NULL
      )
    ''');

    // Tabel balance untuk menyimpan saldo total
    await db.execute('''
      CREATE TABLE IF NOT EXISTS balance (
        id INTEGER PRIMARY KEY,
        amount REAL NOT NULL
      )
    ''');
  }

  // ========== CRUD PERSEDIAAN MAKANAN ==========
  Future<int> insertFood(Food food) async {
    final db = await database;
    final id = await db.insert('persediaan_makanan', food.toMap());
    
    // OTOMATIS: Catat pengeluaran jika harga > 0
    if (food.price > 0) {
      await recordTransaction(
        note: 'Beli Makan: ${food.name}',
        amount: food.price * food.quantity,
        type: 'expense',
        source: 'makanan',
      );
    }
    return id;
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
    final result = await db.query('persediaan_makanan', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final food = Food.fromMap(result.first);
      if (food.price > 0) {
        // Balikkan saldo (refund)
        await recordTransaction(
          note: 'Refund Makanan: ${food.name}',
          amount: food.price * food.quantity,
          type: 'income',
          source: 'makanan',
        );
      }
    }
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
    final id = await db.insert('laundry', laundry.toMap());
    
    // OTOMATIS: Catat biaya laundry
    if (laundry.price > 0) {
      await recordTransaction(
        note: 'Biaya Laundry: ${laundry.type}',
        amount: laundry.price,
        type: 'expense',
        source: 'laundry',
      );
    }
    return id;
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
    final result = await db.query('laundry', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final laundry = Laundry.fromMap(result.first);
      if (laundry.price > 0) {
        await recordTransaction(
          note: 'Refund Laundry: ${laundry.type}',
          amount: laundry.price,
          type: 'income',
          source: 'laundry',
        );
      }
    }
    return await db.delete(
      'laundry',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD PENGELUARAN KOS ==========
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    final id = await db.insert('pengeluaran_kos', expense.toMap());
    
    // Auto-record ke catatan keuangan
    await recordTransaction(
      note: 'Pengeluaran: ${expense.category}',
      amount: expense.amount,
      type: 'expense',
      source: 'pengeluaran_kos',
    );
    
    return id;
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
    final result = await db.query('pengeluaran_kos', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final expense = Expense.fromMap(result.first);
      // recordTransaction otomatis mengupdate saldo via type: 'income'
      await recordTransaction(
        note: 'Refund Pengeluaran: ${expense.category}',
        amount: expense.amount,
        type: 'income', // Uang kembali ke saldo
        source: 'pengeluaran_kos',
      );
    }
    return await db.delete('pengeluaran_kos', where: 'id = ?', whereArgs: [id]);
  }

  // ========== CRUD TAGIHAN BULANAN ==========
  Future<int> insertBill(Bill bill) async {
    final db = await database;
    final id = await db.insert('tagihan_bulanan', bill.toMap());
    
    // Auto-record ke catatan keuangan
    await recordTransaction(
      note: 'Bayar Tagihan: ${bill.name}',
      amount: bill.amount,
      type: 'expense',
      source: 'tagihan',
    );
    
    return id;
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
    final result = await db.query('tagihan_bulanan', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final bill = Bill.fromMap(result.first);
      // recordTransaction otomatis mengupdate saldo via type: 'income'
      await recordTransaction(
        note: 'Refund Tagihan: ${bill.name}',
        amount: bill.amount,
        type: 'income',
        source: 'tagihan',
      );
    }
    return await db.delete('tagihan_bulanan', where: 'id = ?', whereArgs: [id]);
  }

  // ========== SISTEM SALDO (BALANCE) ==========

  // Ambil saldo saat ini
  Future<double> getCurrentBalance() async {
    final db = await database;
    final result = await db.query('balance', where: 'id = 1');
    if (result.isNotEmpty) {
      return (result.first['amount'] as num).toDouble();
    }
    return 0.0;
  }

  // Update saldo (tambah/kurang)
  Future<void> _updateBalance(double change) async {
    final db = await database;
    final current = await getCurrentBalance();
    await db.update(
      'balance',
      {'amount': current + change},
      where: 'id = 1',
    );
  }

  // ========== HELPER OTOMATISASI TRANSAKSI ==========

  // Method pusat untuk mencatat transaksi dari mana saja
  Future<void> recordTransaction({
    required String note,
    required double amount,
    required String type, // 'income' atau 'expense'
    required String source,
  }) async {
    final db = await database;
    
    // 1. Buat object catatan keuangan
    final transaction = FinanceNote(
      note: note,
      amount: amount,
      type: type,
      source: source,
      timestamp: DateTime.now(),
    );

    // 2. Simpan ke tabel catatan_keuangan
    await db.insert('catatan_keuangan', transaction.toMap());

    // 3. Update saldo total
    // Jika income maka +, jika expense maka -
    final change = type == 'income' ? amount : -amount;
    await _updateBalance(change);

    // 4. Beritahu listener bahwa ada transaksi masuk
    _transactionController.add(null);
  }

  // ========== CRUD CATATAN KEUANGAN (VERSI BARU) ==========

  // Insert manual (biasanya dari dialog Tambah Saldo)
  Future<int> insertFinanceNote(FinanceNote note) async {
    final db = await database;
    final id = await db.insert('catatan_keuangan', note.toMap());
    
    // Update saldo setelah insert
    await _updateBalance(note.signedAmount);
    
    // Beritahu listener
    _transactionController.add(null);
    
    return id;
  }

  Future<List<FinanceNote>> getAllFinanceNotes() async {
    final db = await database;
    final result = await db.query(
      'catatan_keuangan',
      orderBy: 'timestamp DESC', // Urutkan dari yang paling baru
    );
    return result.map((map) => FinanceNote.fromMap(map)).toList();
  }

  // Hapus transaksi (juga mengupdate saldo sebaliknya)
  Future<int> deleteFinanceNote(int id) async {
    final db = await database;
    
    // 1. Cari data transaksinya dulu untuk tahu nominalnya
    final result = await db.query('catatan_keuangan', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final note = FinanceNote.fromMap(result.first);
      
      // 2. Balikkan saldonya (kalau pengeluaran dihapus, saldo bertambah)
      await _updateBalance(-note.signedAmount);
      
      // Beritahu listener
      _transactionController.add(null);
    }

    // 3. Hapus datanya
    return await db.delete(
      'catatan_keuangan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ... method CRUD lainnya tetap ada tapi nanti akan kita integrasikan ...

  // ========== CRUD KEBUTUHAN HARIAN ==========
  Future<int> insertDailyNeed(DailyNeed dailyNeed) async {
    final db = await database;
    final id = await db.insert('kebutuhan_harian', dailyNeed.toMap());
    
    // OTOMATIS: Catat pengeluaran
    if (dailyNeed.price > 0) {
      await recordTransaction(
        note: 'Beli Kebutuhan: ${dailyNeed.name}',
        amount: dailyNeed.price * dailyNeed.quantity,
        type: 'expense',
        source: 'harian',
      );
    }
    return id;
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
    final result = await db.query('kebutuhan_harian', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final need = DailyNeed.fromMap(result.first);
      if (need.price > 0) {
        await recordTransaction(
          note: 'Refund Kebutuhan: ${need.name}',
          amount: need.price * need.quantity,
          type: 'income',
          source: 'harian',
        );
      }
    }
    return await db.delete(
      'kebutuhan_harian',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CRUD DAFTAR BELANJA ==========
  Future<int> insertShoppingList(ShoppingList shoppingList) async {
    final db = await database;
    final id = await db.insert('daftar_belanja', shoppingList.toMap());
    
    // OTOMATIS: Catat pengeluaran
    if (shoppingList.price > 0) {
      await recordTransaction(
        note: 'Belanja: ${shoppingList.item}',
        amount: shoppingList.price * shoppingList.quantity,
        type: 'expense',
        source: 'belanja',
      );
    }
    return id;
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
    final result = await db.query('daftar_belanja', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final list = ShoppingList.fromMap(result.first);
      if (list.price > 0) {
        await recordTransaction(
          note: 'Refund Belanja: ${list.item}',
          amount: list.price * list.quantity,
          type: 'income',
          source: 'belanja',
        );
      }
    }
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

