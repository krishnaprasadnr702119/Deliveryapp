import 'package:flutter/material.dart';

class StatusColor {
  static Color getColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Started':
        return Colors.yellow;
      case 'Paused':
        return Colors.orange;
      case 'Pending':
        return Colors.blue;
      default:
        return Colors.white;
    }
  }
}
