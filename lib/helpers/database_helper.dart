import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static const int _dbVersion = 2;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<bool> checkTableExists() async {
    final db = await database;
    List<Map> result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='daily_activities';"
    );
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'is_logged_in = 1',
    );
    return result.isNotEmpty ? result.first : null;
  }

Future<Map<String, dynamic>?> getUserByEmail(String email) async {
  if (email == null) {
    return null;
  }
  
  final db = await database;
  List<Map<String, dynamic>> result = await db.query(
    'users',
    where: 'email = ?',
    whereArgs: [email],
  );
  return result.isNotEmpty ? result.first : null;
}

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,  
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        is_logged_in INTEGER DEFAULT 0
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

    await db.execute('''
      CREATE TABLE daily_activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        exercise TEXT,
        calories REAL,
        water REAL,
        sleep REAL
      )
    ''');

  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE users ADD COLUMN username TEXT NOT NULL DEFAULT ''");
      await db.execute(''' 
        CREATE TABLE IF NOT EXISTS daily_activities (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          exercise TEXT,
          calories REAL,
          water REAL,
          sleep REAL
        )
      ''');
    }
  }

  

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  Future<bool> authenticateUser(String email, String password) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      await db.update(
        'users',
        {'is_logged_in': 1},
        where: 'email = ?',
        whereArgs: [email],
      );
      return true;
    }
    return false;
  }

  Future<int> insertUserProfile(Map<String, dynamic> profile) async {
    Database db = await database;
    return await db.insert('user_profile', profile);
  }

  Future<void> insertActivity(Map<String, dynamic> activity) async {
    final db = await database;
    await db.insert('daily_activities', activity);
  }

 Future<List<Map<String, dynamic>>> getActivityByDate(String date) async {
  final db = await database;
  return await db.query(
    'daily_activities',
    where: 'date = ?',
    whereArgs: [date],
  );
}

  Future<List<Map<String, dynamic>>> getTodayActivities() async {
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await getActivityByDate(date);
  }


  Future<List<Map<String, dynamic>>> getActivities() async {
    Database db = await database;
    return await db.query(
      'daily_activities',
      orderBy: 'date DESC'
    );
  }

  Future<void> logoutUser() async {
    Database db = await database;
    await db.update(
      'users',
      {'is_logged_in': 0},
      where: 'is_logged_in = ?',
      whereArgs: [1],
    );
  }

  Future<void> handleSaveActivity(String date, String exercise, double calories, double water, double sleep) async {
    try {
      final activityData = {
        'date': date,
        'exercise': exercise,
        'calories': calories,
        'water': water,
        'sleep': sleep,
      };
      

          // Log the activity data before saving
    print("Attempting to save activity data:");
    print("Date: $date");
    print("Exercise: $exercise");
    print("Calories: $calories");
    print("Water: $water");
    print("Sleep: $sleep");
      await insertActivity(activityData);
        // Log successful insertion
    print("Activity successfully saved to database.");
    } catch (e) {
      print("Error saving activity: $e");
    }
  }
  

  // Added methods below

  Future<Map<String, dynamic>> getDailySummary(String date) async {
  final db = await database;
  final activities = await db.query(
    'daily_activities',
    where: 'date = ?',
    whereArgs: [date],
  );

  double totalCalories = 0;
  double totalWater = 0;
  int exerciseCount = 0;

  for (var activity in activities) {
    // Explicitly cast to double for 'calories' and 'water'
    totalCalories += (activity['calories'] as num?)?.toDouble() ?? 0.0;
    totalWater += (activity['water'] as num?)?.toDouble() ?? 0.0;
    
    // Cast 'exercise' to String before checking 'isNotEmpty'
    if ((activity['exercise'] as String?)?.isNotEmpty ?? false) {
      exerciseCount++;
    }
  }

  return {
    'calories': totalCalories,
    'water': totalWater,
    'exerciseCount': exerciseCount,
  };
}

  Future<List<Map<String, dynamic>>> getActivityHistory() async {
    final db = await database;
    return await db.query(
      'daily_activities',
      orderBy: 'date DESC',
    );
  }

  Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'user_profile',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUserProfile(int userId, Map<String, dynamic> profile) async {
    final db = await database;
    await db.update(
      'user_profile',
      profile,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteUserProfile(int userId) async {
    final db = await database;
    await db.delete(
      'user_profile',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
