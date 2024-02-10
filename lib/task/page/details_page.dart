import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task/task/bloc/bloc/crud_bloc.dart';
import 'package:task/task/task.dart';
import '../constants/constants.dart';
import '../models/todo.dart';
import '../widgets/custom_text.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final TextEditingController _newTitle = TextEditingController();
  final TextEditingController _newDescription = TextEditingController();
  final TextEditingController _newPin = TextEditingController();
  final TextEditingController _newDate = TextEditingController();
  bool toggleSwitch = false;
  String selectedStatus = 'Pending';
  final List<String> statusOptions = [
    'Completed',
    'Started',
    'Paused',
    'Pending'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            context.read<CrudBloc>().add(const FetchTodos());
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        height: MediaQuery.of(context).size.height,
        child: BlocBuilder<CrudBloc, CrudState>(
          builder: (context, state) {
            if (state is DisplaySpecificTodo) {
              Todo currentTodo = state.todo;

              return Column(
                children: [
                  CustomText(text: 'title'.toUpperCase()),
                  const SizedBox(height: 10),
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      initialValue: currentTodo.title,
                      enabled: false,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomText(text: 'description'.toUpperCase()),
                  const SizedBox(height: 10),
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      initialValue: currentTodo.description,
                      enabled: false,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomText(text: 'date made'.toUpperCase()),
                  const SizedBox(height: 10),
                  CustomText(
                    text: DateFormat.yMMMEd().format(state.todo.createdTime),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext cx) {
                          _newTitle.text = currentTodo.title;
                          _newDescription.text = currentTodo.description;
                          _newPin.text = currentTodo.pin.toString();
                          _newDate.text =
                              DateFormat.yMMMEd().format(currentTodo.date);
                          selectedStatus = currentTodo.status;

                          return StatefulBuilder(
                            builder: ((context, setState) {
                              return AlertDialog(
                                title: const Text(
                                  'Update Task',
                                  style: TextStyle(
                                    fontSize: 25,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Text('Order'),
                                    ),
                                    Flexible(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.blue),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                        ),
                                        maxLines: 1,
                                        controller: _newTitle,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Text('Location'),
                                    ),
                                    Flexible(
                                      child: TextFormField(
                                        controller: _newDescription,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.blue),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                        ),
                                        maxLines: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Text('Pin'),
                                    ),
                                    Flexible(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.blue),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                        ),
                                        maxLines: 1,
                                        controller: _newPin,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Text('Date'),
                                    ),
                                    Flexible(
                                      child: TextFormField(
                                        controller: _newDate,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.blue),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Text('Status'),
                                    ),
                                    DropdownButton<String>(
                                      value: selectedStatus,
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedStatus = newValue!;
                                        });
                                      },
                                      items: statusOptions.map((status) {
                                        return DropdownMenuItem<String>(
                                          value: status,
                                          child: Text(status),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    style: Constants.customButtonStyle,
                                    onPressed: () {
                                      Navigator.pop(cx);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: Constants.customButtonStyle,
                                    onPressed: () async {
                                      context.read<CrudBloc>().add(
                                            UpdateTodo(
                                              todo: Todo(
                                                id: currentTodo.id,
                                                createdTime: DateTime.now(),
                                                description:
                                                    _newDescription.text,
                                                isImportant: toggleSwitch,
                                                number: currentTodo.number,
                                                title: _newTitle.text,
                                                status: selectedStatus,
                                                pin: int.parse(_newPin.text) ??
                                                    0,
                                                date: DateFormat.yMMMEd()
                                                        .parse(_newDate.text) ??
                                                    DateTime.now(),
                                              ),
                                            ),
                                          );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        backgroundColor: Constants.primaryColor,
                                        duration: Duration(seconds: 1),
                                        content: Text('Task updated'),
                                      ));

                                      // Navigate to TaskPage after updating the task
                                      Navigator.popUntil(
                                          context, (route) => route.isFirst);
                                      context
                                          .read<CrudBloc>()
                                          .add(const FetchTodos());
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const TaskPage()),
                                      );
                                    },
                                    child: const Text('Update'),
                                  ),
                                ],
                              );
                            }),
                          );
                        },
                      );
                    },
                    child: const Text('Update'),
                  )
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
