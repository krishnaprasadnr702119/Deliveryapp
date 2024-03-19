import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';

class NavigationScreen extends StatefulWidget {
  final String description;

  NavigationScreen(this.description);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late double latitude;
  late double longitude;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _convertPlaceToCoordinates(widget.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Map'),
        actions: [
          IconButton(
            icon: Icon(Icons.directions),
            onPressed: () {
              _launchDirections(latitude, longitude);
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 15.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('Selected Location'),
                  position: LatLng(latitude, longitude),
                  infoWindow: InfoWindow(title: widget.description),
                ),
              },
            ),
    );
  }

  Future<void> _convertPlaceToCoordinates(String placeName) async {
    try {
      List<Location> locations = await locationFromAddress(placeName);
      if (locations.isNotEmpty) {
        latitude = locations.first.latitude;
        longitude = locations.first.longitude;
        setState(() {
          isLoading = false;
        });
      } else {
        print('No coordinates found for $placeName');
        setState(() {
          isLoading = false;
        });
        // Handle the case where no coordinates are found for the place name
      }
    } catch (e) {
      print('Error converting place to coordinates: $e');
      setState(() {
        isLoading = false;
      });
      // Handle the error
    }
  }

  void _launchDirections(double latitude, double longitude) async {
    String url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("The map is not available");
    }
  }
}
