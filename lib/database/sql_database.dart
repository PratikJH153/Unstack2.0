import 'package:sqflite/sqflite.dart';
import 'package:unstack/data/intial_tasks.dart';
import 'package:unstack/models/tasks/task.model.dart';
import 'package:unstack/utils/app_logger.dart';

class TaskTable {
  static String table = "tasks_table";
  static String columnId = "id";
  static String columnTitle = "title";
  static String columnDescription = "description";
  static String columnPriority = "priority";
  static String columnPriorityIndex = "priorityIndex";
  static String columnCreatedAt = "createdAt";
  static String columnIsCompleted = "isCompleted";
}

class StreakTable {
  static String table = "streak_table";
  static String columnId = "id";
  static String columnDate = "date";
  static String columnTotalTasks = "totalTasks";
  static String columnCompletedTasks = "completedTasks";
  static String columnAllTasksCompleted = "allTasksCompleted";
  static String columnLongestStreak = "longestStreak";
  static String columnCurrentStreak = "currentStreak";
}

class DatabaseService {
  static final DatabaseService instance = DatabaseService._instance();

  DatabaseService._instance();

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await _initDB('tasks.db');
    return _db;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$filePath';

    final database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );

    return database;
  }

  void _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${TaskTable.table} (
        ${TaskTable.columnId} TEXT PRIMARY KEY,
        ${TaskTable.columnTitle} TEXT NOT NULL,
        ${TaskTable.columnDescription} TEXT,
        ${TaskTable.columnPriority} TEXT NOT NULL,
        ${TaskTable.columnCreatedAt} TEXT NOT NULL,
        ${TaskTable.columnIsCompleted} INTEGER NOT NULL,
        ${TaskTable.columnPriorityIndex} INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${StreakTable.table} (
        ${StreakTable.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${StreakTable.columnDate} TEXT NOT NULL,
        ${StreakTable.columnTotalTasks} INTEGER NOT NULL,
        ${StreakTable.columnCompletedTasks} INTEGER NOT NULL,
        ${StreakTable.columnAllTasksCompleted} INTEGER NOT NULL,
        ${StreakTable.columnLongestStreak} INTEGER NOT NULL,
        ${StreakTable.columnCurrentStreak} INTEGER NOT NULL
      )
    ''');
    await initialTasks(db);
  }

  Future<void> initialTasks(Database database) async {
    // Only insert initial tasks if the database is empty
    final existingResults = await database.query(TaskTable.table);
    if (existingResults.isEmpty) {
      final tasks = initalTasks;
      for (var task in tasks) {
        await database.insert(
          TaskTable.table,
          task.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  Future<void> closeDB() async {
    final db = await instance.db;
    db?.close();
  }

  Future<void> deleteDB() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/tasks.db';
    await deleteDatabase(path);
  }

  Future<List<Task>> getTodayTasks() async {
    final Database? db = await this.db;
    final today = DateTime.now();
    final results = await db!.query(
      TaskTable.table,
      where: "strftime('%Y-%m-%d', ${TaskTable.columnCreatedAt}) = ?",
      whereArgs: [today.toIso8601String().split('T')[0]],
    );
    final tasks = results.map((result) => Task.fromJson(result)).toList();
    return tasks;
  }

  Future<List<Task>> getTasks() async {
    final Database? db = await this.db;
    final results = await db!.query(
      TaskTable.table,
      orderBy: '${TaskTable.columnCreatedAt} DESC',
      where: '${TaskTable.columnIsCompleted} = 0',
    );
    final tasks = results.map((result) => Task.fromJson(result)).toList();

    tasks.sort((a, b) {
      if (a.priorityIndex == b.priorityIndex) return 0;
      return a.priorityIndex.compareTo(b.priorityIndex);
    });
    AppLogger.info('Loaded $tasks tasks');

    return tasks;
  }

  Future<void> insertTask(Task task) async {
    final db = await instance.db;
    await db?.insert(
      TaskTable.table,
      task.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(Task task) async {
    final db = await instance.db;
    await db?.update(
      TaskTable.table,
      task.toJson(),
      where: '${TaskTable.columnId} = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> markTaskAsCompleted(String taskID) async {
    final db = await instance.db;
    await db?.update(
      TaskTable.table,
      {TaskTable.columnIsCompleted: 1},
      where: '${TaskTable.columnId} = ?',
      whereArgs: [taskID],
    );
  }

  Future<void> markTaskAsInCompleted(String taskID) async {
    final db = await instance.db;
    await db?.update(
      TaskTable.table,
      {TaskTable.columnIsCompleted: 0},
      where: '${TaskTable.columnId} = ?',
      whereArgs: [taskID],
    );
  }

  Future<void> deleteTask(String taskId) async {
    final db = await instance.db;
    await db?.delete(TaskTable.table,
        where: '${TaskTable.columnId} = ?', whereArgs: [taskId]);
  }

  Future<void> deleteAllTasks() async {
    final db = await instance.db;
    await db?.delete(TaskTable.table);
  }

  Future<void> deleteStreakData() async {
    final db = await instance.db;
    await db?.delete(StreakTable.table);
  }

  /// Insert or update streak data for a specific date
  Future<void> insertOrUpdateStreakData(Map<String, dynamic> streakData) async {
    final db = await instance.db;
    await db?.update(
      StreakTable.table,
      streakData,
      where: '${StreakTable.columnDate} = ?',
      whereArgs: [streakData[StreakTable.columnDate]],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all streak completion history
  Future<List<Map<String, dynamic>>> getStreakHistory() async {
    final db = await instance.db;
    final result = await db?.query(StreakTable.table,
        orderBy: '${StreakTable.columnDate} DESC');
    return result ?? [];
  }

  /// Get streak data for a specific date
  Future<Map<String, dynamic>?> getStreakDataForDate(String date) async {
    final db = await instance.db;
    final result = await db?.query(
      StreakTable.table,
      where: '${StreakTable.columnDate} = ?',
      whereArgs: [date],
      limit: 1,
    );
    return result?.isNotEmpty == true ? result!.first : null;
  }

  /// Delete streak data for a specific date
  Future<void> deleteStreakDataForDate(String date) async {
    final db = await instance.db;
    await db?.delete(
      StreakTable.table,
      where: '${StreakTable.columnDate} = ?',
      whereArgs: [date],
    );
  }

  /// Get current streak count from database
  Future<int> getCurrentStreakFromDB() async {
    final db = await instance.db;
    final result = await db?.query(
      StreakTable.table,
      columns: [StreakTable.columnCurrentStreak],
      orderBy: '${StreakTable.columnDate} DESC',
      limit: 1,
    );

    if (result == null || result.isEmpty) return 0;
    return result.first[StreakTable.columnCurrentStreak] as int? ?? 0;
  }

  /// Get longest streak count from database
  Future<int> getLongestStreakFromDB() async {
    final db = await instance.db;
    final result = await db?.query(
      StreakTable.table,
      columns: ['MAX(${StreakTable.columnLongestStreak}) as maxStreak'],
    );

    if (result == null || result.isEmpty) return 0;
    return result.first['maxStreak'] as int? ?? 0;
  }

  /// Get total completed days count
  Future<int> getTotalCompletedDaysFromDB() async {
    final db = await instance.db;
    final result = await db?.query(
      StreakTable.table,
      where: '${StreakTable.columnAllTasksCompleted} = ?',
      whereArgs: [1],
    );

    return result?.length ?? 0;
  }

  /// Update streak counters in the database
  Future<void> updateStreakCounters(
      int currentStreak, int longestStreak) async {
    final db = await instance.db;
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Update the most recent record with new streak values
    await db?.update(
      StreakTable.table,
      {
        StreakTable.columnCurrentStreak: currentStreak,
        StreakTable.columnLongestStreak: longestStreak,
      },
      where: '${StreakTable.columnDate} = ?',
      whereArgs: [today],
    );
  }
}
