import 'dart:convert';

import 'package:password_hash_plus/password_hash_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:task/src/models/user.dart';
import 'package:task/task/models/todo.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();
  Database? _database;
  Future<void> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'taskp.db');
    _database = await openDatabase(path, version: 2, onCreate: _createDb);
    print("Database initialized.");
  }

  Future<void> _createDb(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY, 
          username TEXT,
          email TEXT,
          password TEXT
        )
      ''');
      await db.execute('''
    CREATE TABLE todos ( 
      userId TEXT,
    _id INTEGER PRIMARY KEY AUTOINCREMENT, 
    isImportant BOOLEAN NOT NULL,
    number INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    time TEXT NOT NULL,
    status TEXT NOT NULL,  
    pin INTEGER NOT NULL,
    date TEXT NOT NULL,
    completedDate TEXT,
    imagePath TEXT,
        FOREIGN KEY (userId) REFERENCES users(id)

  )
''');
    } catch (e) {
      print('Error creating database tables: $e');
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<void> saveUser(User user, {bool resetPassword = false}) async {
    await initDatabase();
    if (_database != null) {
      if (resetPassword) {
        user = user.copyWith(password: _hashPassword(user.password));
        await _database!.update(
          'users',
          user.toMap(),
          where: 'email = ?',
          whereArgs: [user.email],
        );
      } else {
        user = user.copyWith(password: _hashPassword(user.password));
        await _database!.insert(
          'users',
          user.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      final savedUser = await getUserByEmail(user.email);
      print("User saved: $savedUser");
    }
  }

  Future<User?> getUser(String username, String password) async {
    await initDatabase();
    if (_database != null) {
      final List<Map<String, dynamic>> result = await _database!.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      if (result.isNotEmpty) {
        final User user = User.fromMap(result.first);
        if (user.password == _hashPassword(password)) {
          return user;
        }
      }
    }
    return null;
  }

  Future<bool> usernamandemail(String username, String email) async {
    await initDatabase();
    final _database = this._database;
    if (_database != null) {
      final List<Map<String, dynamic>> result = await _database.query(
        'users',
        where: 'username = ? AND email = ?',
        whereArgs: [username, email],
      );
      return result.isNotEmpty;
    }
    return false;
  }

  Future<User?> getUserByEmail(String email) async {
    await initDatabase();
    if (_database != null) {
      final List<Map<String, dynamic>> result = await _database!.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (result.isNotEmpty) {
        return User.fromMap(result.first);
      }
    }
    return null;
  }

  Future<Todo> create(Todo todo) async {
    final db = await _database;
    final id = await db!.insert(todoTable, {
      ...todo.toJson(),
      TodoFields.userId: todo.userId,
      'time': todo.createdTime.toIso8601String(),
    });
    return todo.copyWith(id: id, status: todo.status);
  }

  Future<Todo> readTodo({
    required int id,
  }) async {
    final db = await _database;
    final maps = await db!.query(
      todoTable,
      columns: TodoFields.values,
      where: '${TodoFields.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Todo.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Todo>> readAllTodos({required String userId}) async {
    final db = await _database;
    const where = 'userId = ?';
    const orderBy = '${TodoFields.time} ASC';
    final result = await db!
        .query(todoTable, orderBy: orderBy, where: where, whereArgs: [userId]);
    print(result);
    return result.map((json) => Todo.fromMap(json)).toList();
  }

  Future<int> update({required Todo todo}) async {
    final db = await _database;
    print(todo);
    return db!.update(
      todoTable,
      {
        TodoFields.title: todo.title,
        TodoFields.isImportant: todo.isImportant ? 1 : 0,
        TodoFields.number: todo.number,
        TodoFields.description: todo.description,
        TodoFields.time: todo.createdTime.toIso8601String(),
        TodoFields.status: todo.status,
        TodoFields.pin: todo.pin,
        TodoFields.date: todo.date.toIso8601String(),
        TodoFields.userId: todo.userId,
        TodoFields.completedDate: todo.completedDate?.toIso8601String(),
      },
      where: '${TodoFields.id} = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> delete({required int id}) async {
    final db = await _database;
    return await db!.delete(
      todoTable,
      where: '${TodoFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await _database;
    db!.close();
  }

  Future<List<Todo>> readTodosByStatus(String status,
      {required String userId}) async {
    final List<Map<String, Object?>>? maps = await _database?.query(
      'todos',
      where: 'status = ? AND userId = ?',
      whereArgs: [status, userId],
    );
    return List.generate(maps!.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<List<Todo>> readTodosByDate(DateTime selectedDate,
      {required String userId}) async {
    final DateTime startDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final DateTime endDate = startDate.add(Duration(days: 1));

    final List<Map<String, Object?>>? maps = await _database?.query(
      todoTable,
      where:
          '${TodoFields.time} >= ? AND ${TodoFields.time} < ? AND ${TodoFields.userId} = ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
        userId
      ],
      orderBy: '${TodoFields.time} ASC',
    );

    return List.generate(maps!.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<List<Todo>> readTodosByCompletedDate(DateTime selectedDate,
      {required String userId}) async {
    DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    final List<Map<String, Object?>>? maps = await _database?.query(
      todoTable,
      where:
          '${TodoFields.completedDate} >= ? AND ${TodoFields.completedDate} < ? AND ${TodoFields.userId} = ?',
      whereArgs: [userId],
      orderBy: '${TodoFields.completedDate} ASC, ${TodoFields.time} ASC',
    );

    return List.generate(maps!.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<void> saveImagePathToDb(int todoId, String imagePath) async {
    // Implement the logic to save the image path to the database
    await _database?.update(
      'todos',
      {'imagePath': imagePath},
      where: '_id = ?',
      whereArgs: [todoId],
    );
  }
}
