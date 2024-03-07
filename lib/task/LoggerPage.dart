import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/data/database_helper.dart';
import 'package:task/src/screen/login.dart';
import 'package:task/src/models/user.dart';
import 'package:task/task/bloc/bloc/crud_bloc.dart';
import 'package:task/task/models/todo.dart';
import 'package:task/task/page/add_todo.dart';
import 'package:task/task/page/details_page.dart';
import 'package:task/task/widgets/statuscolor.dart';

class LoggerPage extends StatefulWidget {
  final User? user;

  const LoggerPage({Key? key, this.user}) : super(key: key);

  @override
  _LoggerPageState createState() => _LoggerPageState();
}

class _LoggerPageState extends State<LoggerPage> with WidgetsBindingObserver {
  String? selectedFilter;
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    isLoading = false;
    _checkUserIdInSharedPreferences();
    AppDatabase().initDatabase();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Logs',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<CrudBloc, CrudState>(
        builder: (context, state) {
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8),
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  SingleChildScrollView(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  ),
                  if (state is DisplayTodos && state.todo.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.todo.length,
                        itemBuilder: (context, i) {
                          Todo currentTodo = state.todo[i];

                          return Card(
                            elevation: 10,
                            color: StatusColor.getColor(currentTodo.status),
                            child: ListTile(
                              title: Text(
                                currentTodo.title.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User ID : ${(currentTodo.userId!)}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Status: ${currentTodo.status}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Order Number : ${(currentTodo.id)}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Created: ${(currentTodo.createdTime)}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (currentTodo.completedDate != null)
                                    Text(
                                      'Expected Date to Completed: ${(currentTodo.completedDate!)}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    const Text('No logs'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _applyFilter(String? filter, {DateTime? selectedDate}) {
    setState(() {
      selectedFilter = filter;
    });

    if (filter == null) {
      // print("Fetching all tasks for user: ${widget.user?.id}");
      context.read<CrudBloc>().add(FetchTodos(userId: widget.user?.id ?? ''));
    } else if (filter == 'Created' && selectedDate != null) {
      context.read<CrudBloc>().add(FetchTasksByDate(
            selectedDate: selectedDate,
            userId: widget.user?.id ?? '',
          ));
    } else if (filter == 'Completed' && selectedDate != null) {
      context.read<CrudBloc>().add(FetchTasksByCompletedDate(
            selectedDate: selectedDate,
            userId: widget.user?.id ?? '',
          ));
    } else {
      context.read<CrudBloc>().add(FetchTasksByStatus(
            status: filter,
            userId: widget.user?.id ?? '',
          ));
    }
  }
}
