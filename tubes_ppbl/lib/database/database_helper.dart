import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food.dart';
import '../models/equipment.dart';
import '../models/laundry.dart';

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
      version: 3,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('DROP TABLE IF EXISTS persediaan_makanan');
          await db.execute('DROP TABLE IF EXISTS peralatan_kamar');
          await db.execute('DROP TABLE IF EXISTS laundry');
          await _createDB(db, newVersion);
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

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

