import 'package:flutter/material.dart';

List<DropdownMenuItem<String>> getDropdownItems(String currentStatus) {
  List<String> allowedStatusOptions = [];

  if (currentStatus == 'Pending') {
    allowedStatusOptions = ['Pending', 'Started'];
  } else if (currentStatus == 'Started') {
    allowedStatusOptions = ['Started', 'Paused', 'Completed'];
  } else if (currentStatus == 'Paused') {
    allowedStatusOptions = ['Resume', 'Paused'];
  } else if (currentStatus == 'Resume') {
    allowedStatusOptions = ['Resume', 'Started', 'Paused', 'Completed'];
  }

  return allowedStatusOptions.map((status) {
    return DropdownMenuItem<String>(
      value: status,
      child: Text(status),
    );
  }).toList();
}
