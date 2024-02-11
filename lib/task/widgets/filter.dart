import 'package:flutter/material.dart';

void showFilterPopup(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (selectedDate != null) {
                    // Handle the selected created date
                    print('Selected Created Date: $selectedDate');
                  }
                },
                child: Text('Filter by Created Date'),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (selectedDate != null) {
                    // Handle the selected completed date
                    print('Selected Completed Date: $selectedDate');
                  }
                },
                child: Text('Filter by Completed Date'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
