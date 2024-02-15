import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:password_hash_plus/password_hash_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:task/models/user.dart';
import 'package:task/task/models/todo.dart';
import 'package:uuid/uuid.dart';

const String todoTable = 'todos';
var uuid = Uuid();

class TodoFields {
  static final List<String> values = [
    id,
    isImportant,
    number,
    title,
    description,
    time,
    status,
    pin,
    date,
    completedDate,
  ];

  static const String id = '_id';
  static const String isImportant = 'isImportant';
  static const String number = 'number';
  static const String title = 'title';
  static const String description = 'description';
  static const String time = 'time';
  static const String status = 'status';
  static const String pin = 'pin';
  static const String date = 'date';
  static const String completedDate = 'completedDate';
}

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  AppDatabase._internal();

  Database? _database;

  Future<void> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'tasknew.db');

    _database = await openDatabase(path, version: 2, onCreate: _createDb);
    print("Database initialized.");
  }

  Future<void> _createDb(Database db, int version) async {
    try {
      await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        email TEXT,
        password TEXT
      )
    ''');

      await db.execute('''
      CREATE TABLE $todoTable ( 
        ${TodoFields.id} INTEGER PRIMARY KEY AUTOINCREMENT, 
        ${TodoFields.isImportant} BOOLEAN NOT NULL,
        ${TodoFields.number} INTEGER NOT NULL,
        ${TodoFields.title} TEXT NOT NULL,
        ${TodoFields.description} TEXT NOT NULL,
        ${TodoFields.time} TEXT NOT NULL,
        ${TodoFields.status} TEXT NOT NULL,  
        ${TodoFields.pin} INTEGER NOT NULL,
        ${TodoFields.date} TEXT NOT NULL,
        ${TodoFields.completedDate} TEXT  
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
        user = user.copyWith(
          id: User.generateUserId(),
          password: _hashPassword(user.password),
        );
        await _database!.insert(
          'users',
          user.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print("User saved with ID: ${user.id}");
      }

      print("User saved ");
    }
  }

  String generateUserId() {
    // Using the uuid package to generate a random UUID
    return Uuid().v4();
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
    final id = await db!.insert(todoTable, todo.toJson());
    return todo.copyWith(id: id, status: todo.status);
  }

  Future<Todo> readTodo({required int id}) async {
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

  Future<List<Todo>> readAllTodos() async {
    final db = await _database;
    const orderBy = '${TodoFields.time} ASC';
    final result = await db!.query(todoTable, orderBy: orderBy);

    return result.map((json) => Todo.fromMap(json)).toList();
  }

  Future<int> update({required Todo todo}) async {
    final db = await _database;

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

  Future<List<Todo>> readTodosByStatus(String status) async {
    final List<Map<String, Object?>>? maps = await _database?.query(
      todoTable,
      where: '${TodoFields.status} = ?',
      whereArgs: [status],
    );

    return List.generate(maps!.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<List<Todo>> readTodosByDate(DateTime selectedDate) async {
    final List<Map<String, Object?>>? maps = await _database?.query(
      todoTable,
      where: '${TodoFields.date} = ?',
      whereArgs: [selectedDate.toIso8601String()],
      orderBy: '${TodoFields.time} ASC',
    );

    return List.generate(maps!.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }
}
