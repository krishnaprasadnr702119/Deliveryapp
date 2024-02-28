import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng? selectedLocation;
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition;

    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
        target: currentLocation!,
        zoom: 13.0,
      );
    } else {
      // Default to Trivandrum Kazhakootam coordinates if current location is not available
      initialCameraPosition = CameraPosition(
        target: LatLng(8.5705, 76.8728),
        zoom: 13.0,
      );
    }

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
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _searchAndNavigate();
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
          [
            if (currentLocation != null)
              Marker(
                markerId: MarkerId('currentLocation'),
                position: currentLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
              ),
            if (selectedLocation != null)
              Marker(
                markerId: MarkerId('selectedLocation'),
                position: selectedLocation!,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchAndNavigate() async {
    final input = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Location'),
        content: IntrinsicHeight(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Enter location'),
                    onSubmitted: (value) {
                      Navigator.pop(context, value);
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _confirmSearch());
                      },
                      child: Text('Confirm'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (input == null) return;

    try {
      List<Location> locations = await locationFromAddress(input);

      if (locations.isNotEmpty) {
        final LatLng selected = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );

        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: selected, zoom: 15),
        ));

        setState(() {
          selectedLocation = selected;
        });
      } else {
        print("Location not found");
      }
    } catch (e) {
      print("Error searching location: $e");
    }
  }

  String _confirmSearch() {
    return "Confirmed";
  }
}
