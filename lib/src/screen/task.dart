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
import 'package:task/src/utils/message.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    isLoading = false;
    _checkUserIdInSharedPreferences();
    AppDatabase().initDatabase();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    setState(() {
      initialTaskCount += 10;
      if (initialTaskCount > totalTaskCount) {
        initialTaskCount = totalTaskCount;
      }
    });
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
            onSelected: (String value) {
              _applyFilter(null);
            },
            itemBuilder: (BuildContext context) {
              return [
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
              title: Text('Logger', style: TextStyle(color: Colors.black)),
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
              title: Text('Logout', style: TextStyle(color: Colors.black)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) => AddTodoPage(user: widget.user)),
            ),
          );

          if (result == true) {
            _checkUserIdInSharedPreferences();
          }
        },
        child: Center(
          child: Text(
            'Add Task',
            style: TextStyle(
                fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
          ),
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
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollEndNotification &&
                      _scrollController.position.extentAfter == 0) {
                    // Reach the end of the list, load more items
                    _loadMoreItems();
                  }
                  return false;
                },
                child: Column(
                  children: [
                    SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _applyFilter(null);
                            },
                            child: const Text('All Tasks'),
                          ),
                        ],
                      ),
                    ),
                    if (state is DisplayTodos && state.todo.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
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
                                  color:
                                      StatusColor.getColor(currentTodo.status),
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
                  ],
                ),
              ),
            ),
          );
        },
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

  void _deleteTask(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Message.deleteconf),
          content: Text(Message.confdelete),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(Message.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performDeleteTask(id);
              },
              child: Text(Message.deleted),
            ),
          ],
        );
      },
    );
  }

  void _performDeleteTask(int id) {
    context
        .read<CrudBloc>()
        .add(DeleteTodo(id: id, userId: widget.user?.id ?? ''));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        content: Text(Message.deleted),
        backgroundColor: Colors.green,
      ),
    );
  }
}
