import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:task/models/user.dart';
import 'package:task/task/models/todo.dart';

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
          id TEXT PRIMARY KEY, 
          username TEXT,
          email TEXT,
          password TEXT
        )
      ''');

      await db.execute('''
    CREATE TABLE todos ( 
    _id INTEGER PRIMARY KEY AUTOINCREMENT, 
    isImportant BOOLEAN NOT NULL,
    number INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    time TEXT NOT NULL,
    status TEXT NOT NULL,  
    pin INTEGER NOT NULL,
    date TEXT NOT NULL
  )
''');
    } catch (e) {
      print('Error creating database tables: $e');
    }
  }

  Future<void> saveUser(User user, {bool resetPassword = false}) async {
    await initDatabase();

    if (_database != null) {
      //  print("Saving user: ${user.toMap()}");

      if (resetPassword) {
        await _database!.update(
          'users',
          user.toMap(),
          where: 'email = ?',
          whereArgs: [user.email],
        );
      } else {
        await _database!.insert(
          'users',
          user.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      print("User saved.");
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

        if (user.password == password) {
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
    print(todo);
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
      'todos',
      where: 'status = ?',
      whereArgs: [status],
    );

    return List.generate(maps!.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }
}
