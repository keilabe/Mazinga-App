import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_profile.db');
    return await openDatabase(
      path,
      version: 2,  // Incremented version for schema changes
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute(''' 
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        age INTEGER,
        gender TEXT,
        height REAL,
        weight REAL,
        fitness_goal TEXT,
        activity_level TEXT,
        body_fat REAL,
        profile_picture_path TEXT,
        bmr REAL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  // Insert a new user
  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }


  // Define the authenticateUser method here
  Future<bool> authenticateUser(String email, String password) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty;
  }


  // Insert a new user profile
  Future<int> insertUserProfile(Map<String, dynamic> profile) async {
    Database db = await database;
    return await db.insert('user_profile', profile);
  }

  // Get the profile of a user by user_id
  Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'user_profile',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Update a user profile
  Future<int> updateUserProfile(int userId, Map<String, dynamic> profile) async {
    Database db = await database;
    return await db.update(
      'user_profile',
      profile,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Delete a user profile
  Future<int> deleteUserProfile(int userId) async {
    Database db = await database;
    return await db.delete(
      'user_profile',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Delete a user by email (for account deletion)
  Future<int> deleteUserByEmail(String email) async {
    Database db = await database;
    return await db.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}
