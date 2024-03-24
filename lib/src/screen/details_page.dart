import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/src/models/user.dart';
import 'package:task/src/blocs/Task/crud_bloc.dart';
import 'package:task/src/screen/navigation.dart';
import 'package:task/src/screen/task.dart';
import 'package:task/src/utils/message.dart';
import 'package:task/src/utils/dropdown_util.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/constants.dart';
import '../models/todo.dart';
import '../widgets/custom_text.dart';

class DetailsPage extends StatefulWidget {
  final User? user;

  const DetailsPage({Key? key, this.user}) : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final TextEditingController _newTitle = TextEditingController();
  final TextEditingController _newDescription = TextEditingController();
  final TextEditingController _newPin = TextEditingController();
  final TextEditingController _newDate = TextEditingController();
  int originalPin = 0;
  bool toggleSwitch = false;
  String selectedStatus = 'Pending';
  File? _image;
  final picker = ImagePicker();
  late Todo currentTodo;
  bool statusChanged = false;
  bool isImageSelected = false;

  void _onStatusChanged(String newStatus) {
    setState(() {
      selectedStatus = newStatus;
    });

    currentTodo = currentTodo.copyWith(status: newStatus);
  }

  Future<void> _pickImageAndSaveToDB() async {
    // Show a dialog to choose between gallery and camera
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Image Source"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Row(
                    children: [
                      Icon(Icons.photo_library),
                      SizedBox(width: 8),
                      Text("Gallery"),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImageFromSource(ImageSource.gallery);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt),
                      SizedBox(width: 8),
                      Text("Camera"),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImageFromSource(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getImageFromSource(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      if (_image != null) {
        int todoId = currentTodo.id!;
        await _saveImageToDB(todoId);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('imagePath_$todoId', _image!.path);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            content: Text(Message.image),
          ),
        );

        setState(() {
          isImageSelected = true;
        });
      }
    }
  }

  void _viewImage() async {
    if (_image != null && _image!.path.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              width: double.infinity,
              child: Image.file(File(_image!.path)),
            ),
          );
        },
      );
    } else {
      print("No image available");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedImagePath = prefs.getString('imagePath_${currentTodo.id}');

      if (storedImagePath != null && storedImagePath.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                width: double.infinity,
                child: Image.file(File(storedImagePath)),
              ),
            );
          },
        );
      } else {
        print("No stored image path");
      }
    }
  }

  Future<void> _saveImageToDB(int todoId) async {
    if (_image != null) {
      String imagePath = _image!.path;
      context.read<CrudBloc>().add(SaveImageToDbEvent(
            todoId: todoId,
            imagePath: imagePath,
          ));
    }
  }

  bool isPinRequired() {
    return selectedStatus == 'Completed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TaskPage(
                  user: widget.user,
                ),
              ),
            );
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: BlocBuilder<CrudBloc, CrudState>(
          builder: (context, state) {
            if (state is DisplaySpecificTodo) {
              currentTodo = state.todo;
              originalPin = currentTodo.pin;

              return Column(
                children: [
                  CustomText(text: 'title'.toUpperCase()),
                  const SizedBox(height: 10),
                  tittle(),
                  const SizedBox(height: 10),
                  CustomText(text: 'description'.toUpperCase()),
                  const SizedBox(height: 10),
                  description(),
                  const SizedBox(height: 10),
                  CustomText(text: 'date made'.toUpperCase()),
                  const SizedBox(height: 10),
                  CustomText(
                    text: DateFormat.yMMMEd().format(state.todo.createdTime),
                  ),
                  if (currentTodo.completedDate != null)
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        CustomText(
                            text: 'Expected delivery date'.toUpperCase()),
                        const SizedBox(height: 10),
                        CustomText(
                          text: DateFormat.yMMMEd().format(currentTodo.date),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(280, 40),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext cx) {
                          _newTitle.text = currentTodo.title;
                          _newDescription.text = currentTodo.description;
                          _newPin.text = '';
                          _newDate.text =
                              DateFormat.yMMMEd().format(currentTodo.date);
                          selectedStatus = currentTodo.status;

                          return StatefulBuilder(
                            builder: ((context, setState) {
                              return Center(
                                child: AlertDialog(
                                  title: Text(
                                    Message.updatetask,
                                    style: TextStyle(
                                      fontSize: 25,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: Colors.blue[200],
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Align(
                                          alignment: Alignment.topLeft,
                                          child: Text('Order'),
                                        ),
                                        order(),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(Message.location),
                                        ),
                                        location(),
                                        const SizedBox(height: 10),
                                        if (isPinRequired())
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(Message.pin),
                                          ),
                                        if (isPinRequired()) pin(),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(Message.date),
                                        ),
                                        date(),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(Message.Status),
                                        ),
                                        DropdownButton<String>(
                                          value: selectedStatus,
                                          onChanged: (newValue) {
                                            setState(() {
                                              selectedStatus = newValue!;
                                            });
                                          },
                                          items:
                                              getDropdownItems(selectedStatus),
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                          dropdownColor: Colors.white,
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(280, 40),
                                      ),
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => TaskPage(
                                                      user: widget.user,
                                                    )));
                                      },
                                      child: Text(Message.cancel),
                                    ),
                                    Visibility(
                                      visible: selectedStatus == 'Completed',
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(280, 40),
                                        ),
                                        onPressed: () async {
                                          await _pickImageAndSaveToDB();
                                          setState(() {
                                            isImageSelected = true;
                                          });
                                        },
                                        child: Text(Message.addimage),
                                      ),
                                    ),
                                    updatingtask(context),
                                  ],
                                ),
                              );
                            }),
                          );
                        },
                      );
                    },
                    child: Text(Message.update),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(280, 40),
                    ),
                    onPressed: () {
                      _viewImage();
                    },
                    child: Text(Message.viewimage),
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  ElevatedButton updatingtask(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(280, 40),
      ),
      onPressed: () async {
        if (isPinRequired() &&
            (_newPin.text.isEmpty || _newPin.text.length != 4)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              duration: Duration(seconds: 1),
              content: Text(Message.addpin),
            ),
          );
          return;
        }
        if (selectedStatus == 'Started') {
          statusChanged = true;
          String description = _newDescription.text;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NavigationScreen(description),
            ),
          );
        }

        DateTime? completedDate;
        if (isPinRequired()) {
          completedDate = DateTime.now();
        }
        if (currentTodo.status != selectedStatus) {
          // Update the status in the currentTodo object
          currentTodo = currentTodo.copyWith(status: selectedStatus);

          context.read<CrudBloc>().add(
                UpdateTodo(
                  todo: Todo(
                    id: currentTodo.id,
                    createdTime: currentTodo.createdTime,
                    description: _newDescription.text,
                    isImportant: toggleSwitch,
                    number: currentTodo.number,
                    title: _newTitle.text,
                    status: selectedStatus,
                    pin:
                        isPinRequired() ? int.parse(_newPin.text) : originalPin,
                    date: DateFormat.yMMMEd().parse(_newDate.text),
                    completedDate: completedDate,
                    imagePath: _image?.path,
                    userId: widget.user?.id ?? '',
                  ),
                  userId: widget.user?.id ?? '',
                ),
              );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
              content: Text(Message.taskupdated),
            ),
          );

          Navigator.popUntil(context, (route) => route.isFirst);

          context
              .read<CrudBloc>()
              .add(FetchTodos(userId: widget.user?.id ?? ''));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskPage(
                user: widget.user,
              ),
            ),
          );
        }
      },
      child: Text(Message.update),
    );
  }

  Flexible date() {
    return Flexible(
      child: TextFormField(
        controller: _newDate,
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
        maxLines: 1,
      ),
    );
  }

  Flexible pin() {
    return Flexible(
      child: TextFormField(
        obscureText: true,
        maxLength: 4,
        keyboardType: TextInputType.number,
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
        maxLines: 1,
        controller: _newPin,
      ),
    );
  }

  Flexible location() {
    return Flexible(
      child: TextFormField(
        controller: _newDescription,
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
        maxLines: 2,
      ),
    );
  }

  Flexible order() {
    return Flexible(
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
        maxLines: 1,
        controller: _newTitle,
      ),
    );
  }

  Flexible description() {
    return Flexible(
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
    );
  }

  Flexible tittle() {
    return Flexible(
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
    );
  }
}
