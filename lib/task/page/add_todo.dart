import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:task/task/bloc/bloc/crud_bloc.dart';
import 'package:task/task/widgets/custom_text.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({Key? key}) : super(key: key);

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String selectedStatus = 'Pending';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'order'.toUpperCase()),
                TextFormField(
                  controller: _title,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomText(text: 'location'.toUpperCase()),
                TextFormField(
                  controller: _description,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomText(text: 'Pin'.toUpperCase()),
                TextFormField(
                  controller: _pinController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                CustomText(text: 'date'.toUpperCase()),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onTap: () {
                    // Show date picker when the text field is tapped
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        // Format the selected date in yyyy-MM-dd format
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                        _dateController.text = formattedDate;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<CrudBloc, CrudState>(
                  builder: (context, state) {
                    return Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_title.text.isNotEmpty &&
                              _description.text.isNotEmpty &&
                              _pinController.text.isNotEmpty &&
                              _dateController.text.isNotEmpty) {
                            try {
                              // Parse the pin as an integer
                              int pin = _pinController.text.isNotEmpty
                                  ? int.tryParse(_pinController.text) ?? 0
                                  : 0;

                              // Parse and validate the date
                              DateTime parsedDate =
                                  DateTime.parse(_dateController.text);

                              if (parsedDate.isAfter(DateTime.now())) {
                                context.read<CrudBloc>().add(
                                      AddTodo(
                                        title: _title.text,
                                        isImportant: false,
                                        number: 0,
                                        description: _description.text,
                                        createdTime: DateTime.now(),
                                        status: selectedStatus,
                                        pin: pin,
                                        date: parsedDate,
                                      ),
                                    );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Text("Task successfully"),
                                  ),
                                );
                                context
                                    .read<CrudBloc>()
                                    .add(const FetchTodos());
                                Navigator.pop(context);
                              } else {
                                print("Invalid date: $parsedDate");
                                // Handle case where parsedDate is not valid
                                // You may want to show an error message or take appropriate action
                              }
                            } catch (e) {
                              print("Error parsing date: $e");
                              // Handle the error when parsing the date
                              // Provide a default date or handle the error as needed
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "All fields must be filled",
                                ),
                              ),
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.all(20),
                          ),
                          minimumSize: MaterialStateProperty.all(
                            Size(400, 60),
                          ),
                        ),
                        child: const Text('Submit'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
