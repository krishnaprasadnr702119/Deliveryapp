// logger_page.dart

import 'package:flutter/material.dart';
import 'package:task/src/models/user.dart';
import 'logger.dart'; // Import your logger class or library

class LoggerPage extends StatelessWidget {
  final User? user;
  final List<String> logs;

  LoggerPage({required this.logs, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logger'),
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(logs[index]),
          );
        },
      ),
    );
  }
}
