const String todoTable = 'todos';

class TodoFields {
  static final List<String> values = [
    id, isImportant, number, title, description, time, status // Add status
  ];

  static const String id = '_id';
  static const String isImportant = 'isImportant';
  static const String number = 'number';
  static const String title = 'title';
  static const String description = 'description';
  static const String time = 'time';
  static const String status = 'status'; // Add status
}

class Todo {
  final int? id;
  final bool isImportant;
  final int number;
  final String title;
  final String description;
  final DateTime createdTime;
  final String status; // Add status

  const Todo({
    this.id,
    required this.isImportant,
    required this.number,
    required this.title,
    required this.description,
    required this.createdTime,
    required this.status, // Include status
  });

  Todo copyWith({
    int? id,
    bool? isImportant,
    int? number,
    String? title,
    String? description,
    DateTime? createdTime,
    String? status,
  }) {
    return Todo(
      id: id ?? this.id,
      isImportant: isImportant ?? this.isImportant,
      number: number ?? this.number,
      title: title ?? this.title,
      description: description ?? this.description,
      createdTime: createdTime ?? this.createdTime,
      status: status ?? this.status,
    );
  }

  static Todo fromJson(Map<String, Object?> json) => Todo(
        id: json[TodoFields.id] as int?,
        isImportant: json[TodoFields.isImportant] == 1,
        number: json[TodoFields.number] as int,
        title: json[TodoFields.title] as String,
        description: json[TodoFields.description] as String,
        createdTime: DateTime.parse(json[TodoFields.time] as String),
        status: json[TodoFields.status] as String, // Include status
      );

  Map<String, Object?> toJson() => {
        TodoFields.id: id,
        TodoFields.title: title,
        TodoFields.isImportant: isImportant ? 1 : 0,
        TodoFields.number: number,
        TodoFields.description: description,
        TodoFields.time: createdTime.toIso8601String(),
        TodoFields.status: status, // Include status
      };
}
