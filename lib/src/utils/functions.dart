import 'package:url_launcher/url_launcher.dart';

class AllFunctions {
  static Future<void> openGoogleMaps(String location) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$location';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
  }
}
