// dropdown_util.dart

import 'package:flutter/material.dart';

List<DropdownMenuItem<String>> getDropdownItems(String currentStatus) {
  List<String> allowedStatusOptions = [];

  // Customize the allowed status options based on the current status
  if (currentStatus == 'Pending') {
    allowedStatusOptions = ['Pending', 'Started'];
  } else if (currentStatus == 'Started') {
    allowedStatusOptions = ['Started', 'Paused', 'Completed'];
  } else if (currentStatus == 'Paused') {
    allowedStatusOptions = ['Completed', 'Paused'];
  }

  return allowedStatusOptions.map((status) {
    return DropdownMenuItem<String>(
      value: status,
      child: Text(status),
    );
  }).toList();
}
