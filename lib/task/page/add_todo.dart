import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:task/src/models/user.dart';
import 'package:task/task/bloc/bloc/crud_bloc.dart';
import 'package:task/task/widgets/custom_text.dart';

class AddTodoPage extends StatefulWidget {
  final User? user;

  const AddTodoPage({Key? key, this.user}) : super(key: key);

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String selectedStatus = 'Pending';

  @override
  void initState() {
    super.initState();
    _generateRandomPin();
  }

  void _generateRandomPin() {
    // Generate a random 4-digit pin
    Random random = Random();
    int randomPin = random.nextInt(9000) + 1000;
    _pinController.text = randomPin.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'order'.toUpperCase()),
                TextFormField(
                  controller: _title,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomText(text: 'location'.toUpperCase()),
                TextFormField(
                  controller: _locationController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onTap: () {
                    _navigateToMapScreen();
                  },
                ),
                const SizedBox(height: 16),
                CustomText(text: 'Pin'.toUpperCase()),
                TextFormField(
                  controller: _pinController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                CustomText(text: 'date'.toUpperCase()),
                TextFormField(
                  controller: _dateController,
                  style: TextStyle(color: Colors.white),
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
                        setState(() {
                          _dateController.text = formattedDate;
                        });
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
                              _locationController.text.isNotEmpty &&
                              _pinController.text.isNotEmpty &&
                              _dateController.text.isNotEmpty) {
                            try {
                              // Parse the pin as an integer
                              int pin = _pinController.text.isNotEmpty
                                  ? int.tryParse(_pinController.text) ?? 0
                                  : 0;

                              // Parse and validate the date
                              if (_dateController.text.isNotEmpty) {
                                DateTime? parsedDate;

                                try {
                                  parsedDate =
                                      DateTime.parse(_dateController.text);
                                } catch (e) {
                                  print("Error parsing date: $e");
                                }

                                if (parsedDate != null &&
                                    parsedDate.isAfter(DateTime.now())) {
                                  context.read<CrudBloc>().add(
                                        AddTodo(
                                          title: _title.text,
                                          isImportant: false,
                                          number: 0,
                                          description: _locationController.text,
                                          createdTime: DateTime.now(),
                                          status: selectedStatus,
                                          pin: pin,
                                          date: parsedDate,
                                          userId: widget.user!.id,
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Duration(seconds: 1),
                                      content: Text("Task successfully"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  context.read<CrudBloc>().add(
                                        FetchTodos(
                                            userId: widget.user?.id ?? ''),
                                      );
                                  Navigator.pop(context);
                                } else {
                                  print("Invalid date: $parsedDate");
                                }
                              } else {
                                print("Date field is empty");
                              }
                            } catch (e) {
                              print("Error parsing date: $e");
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("All fields must be filled"),
                                backgroundColor: Colors.green,
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

  void _navigateToMapScreen() async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        _locationController.text =
            "(${selectedLocation.latitude}, ${selectedLocation.longitude})";
      });
    }
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng? selectedLocation;

  @override
  Widget build(BuildContext context) {
    // Provide an initial camera position
    CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(8.5705, 76.8728), // Trivandrum Kazhakootam coordinates
      zoom: 13.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, selectedLocation);
            },
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: initialCameraPosition,
        onTap: (LatLng location) {
          setState(() {
            selectedLocation = location;
          });
        },
        markers: Set<Marker>.of(
          selectedLocation != null
              ? [
                  Marker(
                    markerId: MarkerId('selectedLocation'),
                    position: selectedLocation!,
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}
