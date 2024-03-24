import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/src/data/database_helper.dart';
import 'package:task/src/models/user.dart';
import 'package:task/src/blocs/Task/crud_bloc.dart';
import 'package:task/src/models/todo.dart';
import 'package:task/src/utils/message.dart';
import 'package:task/src/widgets/statuscolor.dart';

class LoggerPage extends StatefulWidget {
  final User? user;

  const LoggerPage({Key? key, this.user}) : super(key: key);

  @override
  _LoggerPageState createState() => _LoggerPageState();
}

class _LoggerPageState extends State<LoggerPage> with WidgetsBindingObserver {
  String? selectedFilter;
  late bool isLoading;
  late List<Todo> logs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    isLoading = false;
    logs = [];
    _checkUserIdInSharedPreferences();
    AppDatabase().initDatabase();

    // Listen to CRUD events
    context.read<CrudBloc>().stream.listen((state) {
      if (state is DisplayTodos && state.todo.isNotEmpty) {
        // Update log file after a task is deleted
        _updateLogAfterDeletion(state.todo.first);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkUserIdInSharedPreferences();
    }
  }

  Future<void> _checkUserIdInSharedPreferences() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        context.read<CrudBloc>().add(FetchTodos(userId: userId));
      }
    } catch (e) {
      print('Error checking user ID: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveLogsToFile(List<Todo> todos) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/log.txt');
    String content = '';

    for (Todo todo in todos) {
      content += 'Title: ${todo.title}\n';
      content += 'User ID: ${todo.userId}\n';
      content += 'Status: ${todo.status}\n';
      content += 'Order Number: ${todo.id}\n';
      content += 'Created Time: ${todo.createdTime}\n';
      if (todo.completedDate != null) {
        content += 'Expected Completion Date: ${todo.completedDate}\n';
      }
      content += '\n';
    }

    await file.writeAsString(content);
  }

  Future<List<Todo>> _readLogsFromFile() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/log.txt');
      if (!file.existsSync()) {
        return []; // Return an empty list if the file doesn't exist
      }
      String fileContent = await file.readAsString();

      List<Todo> todos = [];
      List<String> logLines = fileContent.split('\n\n');
      for (String logLine in logLines) {
        List<String> logFields = logLine.split('\n');
        if (logFields.length >= 5) {
          // Check if logFields has at least 5 elements
          Todo todo = Todo(
              title: logFields[0].split(': ')[1],
              userId: logFields[1].split(': ')[1],
              status: logFields[2].split(': ')[1],
              id: int.parse(logFields[3].split(': ')[1]),
              createdTime: DateTime.parse(logFields[4].split(': ')[1]),
              completedDate: logFields.length >= 6
                  ? DateTime.parse(logFields[5].split(': ')[1])
                  : null,
              imagePath: logLine.contains('Image Path')
                  ? logFields[6].split(': ')[1]
                  : null,
              isImportant: false,
              number: 0,
              description: '',
              pin: 0,
              date: DateTime.now());
          todos.add(todo);
        }
      }

      return todos;
    } catch (e) {
      print('Error reading logs from file: $e');
      return [];
    }
  }

  Future<void> _updateLogAfterDeletion(Todo deletedTodo) async {
    try {
      // Read existing log file content
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/log.txt');
      String fileContent = await file.readAsString();

      // Append deleted task details to the log file
      String deletionLog = 'Title: ${deletedTodo.title}\n'
          'User ID: ${deletedTodo.userId}\n'
          'Status: ${deletedTodo.status}\n'
          'Order Number: ${deletedTodo.id}\n'
          'Created Time: ${deletedTodo.createdTime}\n'
          'Deleted Time: ${DateTime.now()}\n\n';

      await file.writeAsString('$fileContent$deletionLog');
    } catch (e) {
      print('Error updating log after deletion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          Message.logs,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<CrudBloc, CrudState>(
        listener: (context, state) {
          if (state is DisplayTodos && state.todo.isNotEmpty) {
            logs = state.todo;
            _saveLogsToFile(logs);
          }
        },
        child: SafeArea(
          child: FutureBuilder<List<Todo>>(
            future: _readLogsFromFile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<Todo> todos = snapshot.data ?? [];
                return todos.isNotEmpty
                    ? ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          Todo todo = todos[index];
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    todo.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text('Created Date: ${todo.createdTime}'),
                                  if (todo.completedDate != null)
                                    Text(
                                        'Completed Date: ${todo.completedDate}'),
                                  Text('Status: ${todo.status}'),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(child: Text('No logs'));
              }
            },
          ),
        ),
      ),
    );
  }
}
