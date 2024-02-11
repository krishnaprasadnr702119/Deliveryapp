import 'dart:convert';

import 'package:intl/intl.dart';

const String todoTable = 'todos';

class TodoFields {
  static final List<String> values = [
    id,
    isImportant,
    number,
    title,
    description,
    time,
    status,
    pin,
    date,
  ];

  static const String id = '_id';
  static const String isImportant = 'isImportant';
  static const String number = 'number';
  static const String title = 'title';
  static const String description = 'description';
  static const String time = 'time';
  static const String status = 'status';
  static const String pin = 'pin';
  static const String date = 'date';
}

class Todo {
  final int? id;
  final bool isImportant;
  final int number;
  final String title;
  final String description;
  final DateTime createdTime;
  final String status;
  final int pin;
  final DateTime date;

  Todo({
    this.id,
    required this.isImportant,
    required this.number,
    required this.title,
    required this.description,
    required this.createdTime,
    required this.status,
    required this.pin,
    required this.date,
  });

  Todo copyWith({
    int? id,
    bool? isImportant,
    int? number,
    String? title,
    String? description,
    DateTime? createdTime,
    String? status,
    int? pin,
    DateTime? date,
  }) {
    return Todo(
      id: id ?? this.id,
      isImportant: isImportant ?? this.isImportant,
      number: number ?? this.number,
      title: title ?? this.title,
      description: description ?? this.description,
      createdTime: createdTime ?? this.createdTime,
      status: status ?? this.status,
      pin: pin ?? this.pin,
      date: date ?? this.date,
    );
  }

  /// Deserialize from JSON
  factory Todo.fromJson(String jsonString) {
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return Todo.fromMap(jsonMap);
  }

  /// Deserialize from Map
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map[TodoFields.id] as int?,
      isImportant: map[TodoFields.isImportant] == 1,
      number: map[TodoFields.number] as int,
      title: map[TodoFields.title] as String,
      description: map[TodoFields.description] as String,
      createdTime: DateTime.parse(map[TodoFields.time] as String),
      status: map[TodoFields.status] as String,
      pin: map[TodoFields.pin] != null ? (map[TodoFields.pin] as int) : 0,
      date: _parseDate(map[TodoFields.date]),
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        TodoFields.id: id,
        TodoFields.title: title,
        TodoFields.isImportant: isImportant ? 1 : 0,
        TodoFields.number: number,
        TodoFields.description: description,
        TodoFields.time: createdTime.toIso8601String(),
        TodoFields.status: status,
        TodoFields.pin: pin,
        TodoFields.date: DateFormat('MM/dd/yy').format(date),
      };

  /// Helper method to parse date with custom format and error handling
  static DateTime _parseDate(dynamic dateString) {
    try {
      if (dateString is String) {
        return DateFormat('MM/dd/yy').parse(dateString);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return DateTime.now();
  }

  /// Validate the Todo object
  bool isValid() {
    return pin >= 0 && date.isAfter(DateTime.now());
  }
}
