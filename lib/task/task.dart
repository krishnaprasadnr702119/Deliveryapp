import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/login/screen/login.dart';
import 'package:task/models/user.dart';
import 'package:task/task/bloc/bloc/crud_bloc.dart';
import 'package:task/task/models/todo.dart';
import 'package:task/task/page/add_todo.dart';
import 'package:task/task/page/details_page.dart';
import 'package:task/task/widgets/filter.dart';

class TaskPage extends StatefulWidget {
  final User? user;

  const TaskPage({Key? key, this.user}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  @override
  void initState() {
    super.initState();
    context.read<CrudBloc>().add(const FetchTodos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text('Delivery'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              print('Filtering tasks...');
              showFilterPopup(context);
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
        child: const Icon(
          Icons.add,
          color: Colors.black87,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const AddTodoPage()),
          );
        },
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
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<CrudBloc>().add(const FetchTodos());
                          },
                          child: const Text('All Tasks'),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<CrudBloc>()
                                .add(FetchTasksByStatus(status: 'Completed'));
                          },
                          child: const Text('Completed Tasks'),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<CrudBloc>()
                                .add(FetchTasksByStatus(status: 'Pending'));
                          },
                          child: const Text('Pending Tasks'),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<CrudBloc>()
                                .add(FetchTasksByStatus(status: 'Started'));
                          },
                          child: const Text('Started Tasks'),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<CrudBloc>()
                                .add(FetchTasksByStatus(status: 'Paused'));
                          },
                          child: const Text('Paused Tasks'),
                        ),
                      ],
                    ),
                  ),
                  if (state is DisplayTodos && state.todo.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.todo.length,
                        itemBuilder: (context, i) {
                          Todo currentTodo = state.todo[i];
                          Color statusColor = Colors.white;

                          if (currentTodo.status == 'Completed') {
                            statusColor = Colors.green;
                          } else if (currentTodo.status == 'Started') {
                            statusColor = Colors.yellow;
                          } else if (currentTodo.status == 'Paused') {
                            statusColor = Colors.orange;
                          } else if (currentTodo.status == 'Pending') {
                            statusColor = Colors.blue;
                          }

                          return GestureDetector(
                            onTap: () {
                              context
                                  .read<CrudBloc>()
                                  .add(FetchSpecificTodo(id: currentTodo.id!));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: ((context) => const DetailsPage()),
                                ),
                              );
                            },
                            child: Container(
                              height: 80,
                              margin: const EdgeInsets.only(bottom: 14),
                              child: Card(
                                elevation: 10,
                                color: statusColor,
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        currentTodo.title.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Status: ${currentTodo.status}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              context.read<CrudBloc>().add(
                                                  DeleteTodo(
                                                      id: currentTodo.id!));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    duration: Duration(
                                                        milliseconds: 500),
                                                    content:
                                                        Text("Deleted Task"),
                                                    backgroundColor:
                                                        Colors.green),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
          );
        },
      ),
    );
  }
}
