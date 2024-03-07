import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationScreen extends StatelessWidget {
  final double latitude;
  final double longitude;

  NavigationScreen(this.latitude, this.longitude);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Map'),
        actions: [
          IconButton(
            icon: Icon(Icons.directions),
            onPressed: () {
              _launchDirections();
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('Selected Location'),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: 'Selected Location'),
          ),
        },
      ),
    );
  }

  void _launchDirections() async {
    String url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("the map is not available");
    }
  }
}
