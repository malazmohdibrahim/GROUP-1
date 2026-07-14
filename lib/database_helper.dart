import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'study_planner.db');

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        hours INTEGER NOT NULL,
        done INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> insertGoal({required String subject, required int hours}) async {
    final db = await instance.database;

    return await db.insert('goals', {
      'subject': subject,
      'hours': hours,
      'done': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getGoals() async {
    final db = await instance.database;

    return await db.query('goals', orderBy: 'id DESC');
  }

  Future<int> updateGoalDone({required int id, required bool done}) async {
    final db = await instance.database;

    return await db.update(
      'goals',
      {'done': done ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await instance.database;

    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }
}
