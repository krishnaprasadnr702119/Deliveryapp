import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/models/user.dart';
import 'package:task/task/bloc/bloc/crud_bloc.dart';
import 'package:task/task/page/add_todo.dart';
import 'package:task/task/page/details_page.dart';

class TaskPage extends StatelessWidget {
  final User? user;

  const TaskPage({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: user != null
                  ? Text(user!.username, style: TextStyle(color: Colors.black))
                  : null,
              accountEmail: user != null
                  ? Text(user!.email, style: TextStyle(color: Colors.black))
                  : null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(user?.username.substring(0, 1) ?? ''),
              ),
              margin: EdgeInsets.zero,
              currentAccountPictureSize: Size.square(72),
            ),
            ListTile(
              title: Text('Logger', style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              title: Text('Logger', style: TextStyle(color: Colors.black)),
              onTap: () {},
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
          if (state is CrudInitial) {
            context.read<CrudBloc>().add(const FetchTodos());
          }
          if (state is DisplayTodos) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(8),
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Add Task'.toUpperCase(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    state.todo.isNotEmpty
                        ? Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              padding: const EdgeInsets.all(8),
                              itemCount: state.todo.length,
                              itemBuilder: (context, i) {
                                Color statusColor = Colors.white;

                                if (state.todo[i].status == 'Completed') {
                                  statusColor = Colors.green;
                                } else if (state.todo[i].status == 'Started') {
                                  statusColor = Colors.yellow;
                                } else if (state.todo[i].status == 'Paused') {
                                  statusColor = Colors.orange;
                                } else if (state.todo[i].status == 'Pending') {
                                  statusColor = Colors.red;
                                }

                                return GestureDetector(
                                  onTap: () {
                                    context.read<CrudBloc>().add(
                                        FetchSpecificTodo(
                                            id: state.todo[i].id!));
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: ((context) =>
                                            const DetailsPage()),
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
                                              state.todo[i].title.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(
                                              'Status: ${state.todo[i].status}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    context
                                                        .read<CrudBloc>()
                                                        .add(DeleteTodo(
                                                            id: state
                                                                .todo[i].id!));
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        duration: Duration(
                                                            milliseconds: 500),
                                                        content: Text(
                                                            "Deleted todo"),
                                                      ),
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
                        : const Text(''),
                  ],
                ),
              ),
            );
          }
          return Container(
            color: Colors.white,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
