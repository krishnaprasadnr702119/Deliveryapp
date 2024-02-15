import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/task/bloc/bloc/crud_bloc.dart';

class Filter {
  static Future<void> showFilterOptionsPopup(
      BuildContext context, DateTime selectedDate) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Handle filtering by created date
                  context.read<CrudBloc>().add(const FetchTasksByStatus(
                        status: 'Filter by created date',
                      ));
                },
                child: const Text('Filter by Created Date'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Handle filtering by complete date
                  context.read<CrudBloc>().add(const FetchTasksByStatus(
                        status: 'Filter by complete date',
                      ));
                },
                child: const Text('Filter by Complete Date'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Fetch tasks for the selected date in ascending order
                  context.read<CrudBloc>().add(FetchTasksByDate(
                        selectedDate: selectedDate,
                      ));
                },
                child: const Text('Filter by Date (Ascending Order)'),
              ),
            ],
          ),
        );
      },
    );
  }
}
