import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/src/data/database_helper.dart';
import 'package:task/src/screen/login.dart';
import 'package:task/src/models/user.dart';
import 'package:task/src/blocs/Task/crud_bloc.dart';
import 'package:task/src/models/todo.dart';
import 'package:task/src/screen/add_todo.dart';
import 'package:task/src/screen/details_page.dart';
import 'package:task/src/widgets/statuscolor.dart';
import 'package:task/src/screen/LoggerPage.dart';

class TaskPage extends StatefulWidget {
  final User? user;

  const TaskPage({Key? key, this.user}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with WidgetsBindingObserver {
  String? selectedFilter;
  late bool isLoading;
  int initialTaskCount = 10;
  int totalTaskCount = 0;

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
          'Delivery',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (String value) {
              _applyFilter(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: null,
                  child: Text(
                    'Filter',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Completed',
                  child: Text('Completed Tasks'),
                ),
                const PopupMenuItem<String>(
                  value: 'Pending',
                  child: Text('Pending Tasks'),
                ),
                const PopupMenuItem<String>(
                  value: 'Started',
                  child: Text('Started Tasks'),
                ),
                PopupMenuItem<String>(
                  value: 'Created',
                  child: Text('Filter by Created Date'),
                  onTap: () async {
                    await _selectDate(context, filter: 'Created');
                  },
                ),
                PopupMenuItem<String>(
                  value: 'Completed',
                  child: Text('Filter by Completed Date'),
                  onTap: () async {
                    await _selectDate(context, filter: 'Completed');
                  },
                ),
              ];
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: widget.user != null
                  ? Text(widget.user!.username,
                      style: TextStyle(color: Colors.white))
                  : null,
              accountEmail: widget.user != null
                  ? Text(widget.user!.email,
                      style: TextStyle(color: Colors.white))
                  : null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(widget.user?.username.substring(0, 1) ?? ''),
              ),
              margin: EdgeInsets.zero,
              currentAccountPictureSize: Size.square(72),
            ),
            ListTile(
              title: Text('Logger',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => LoggerPage(
                            user: widget.user,
                          )),
                );
              },
            ),
            ListTile(
              title: Text('Logout',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<CrudBloc, CrudState>(
        builder: (context, state) {
          if (state is DisplayTodos) {
            totalTaskCount = state.todo.length;
          }
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
                      // children: [
                      //   ElevatedButton(
                      //     onPressed: () {
                      //       _applyFilter(null);
                      //     },
                      //     child: const Text('All Tasks'),
                      //   ),
                      // ],
                    ),
                  ),
                  if (state is DisplayTodos && state.todo.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: initialTaskCount <= state.todo.length
                            ? initialTaskCount
                            : state.todo.length,
                        itemBuilder: (context, i) {
                          Todo currentTodo = state.todo[i];
                          return GestureDetector(
                            onTap: () async {
                              context.read<CrudBloc>().add(FetchSpecificTodo(
                                    id: currentTodo.id!,
                                    userId: widget.user?.id ?? '',
                                  ));
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: ((context) =>
                                      DetailsPage(user: widget.user)),
                                ),
                              );

                              if (result == true) {
                                _checkUserIdInSharedPreferences();
                              }
                            },
                            child: Container(
                              height: 80,
                              margin: const EdgeInsets.only(bottom: 14),
                              child: Card(
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
                                  subtitle: Text(
                                    'Status: ${currentTodo.status}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _deleteTask(currentTodo.id!);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    const Text('No tasks'),
                  if (initialTaskCount < totalTaskCount)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          initialTaskCount += 10;
                          if (initialTaskCount > totalTaskCount) {
                            initialTaskCount = totalTaskCount;
                          }
                        });
                      },
                      child: Text('Load More'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(6.0),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => AddTodoPage(user: widget.user)),
            );
          },
          child: Text(
            'Add Task',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context,
      {required String filter}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      _applyFilter(filter, selectedDate: pickedDate);
    }
  }

  void _applyFilter(String? filter, {DateTime? selectedDate}) {
    setState(() {
      selectedFilter = filter;
    });

    if (filter == null) {
      print("Fetching all tasks for user: ${widget.user?.id}");
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

  void _deleteTask(int Id) {
    context
        .read<CrudBloc>()
        .add(DeleteTodo(id: Id, userId: widget.user?.id ?? ''));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        content: Text("Deleted Task"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
