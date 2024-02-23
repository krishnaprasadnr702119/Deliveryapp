part of 'crud_bloc.dart';

abstract class CrudEvent extends Equatable {
  const CrudEvent();
}

class AddTodo extends CrudEvent {
  final String title;
  final bool isImportant;
  final int number;
  final String description;
  final DateTime createdTime;
  final String status;
  final int pin;
  final DateTime date;
  final String userId;

  const AddTodo(
      {required this.title,
      required this.isImportant,
      required this.number,
      required this.description,
      required this.createdTime,
      required this.status,
      required this.pin,
      required this.date,
      required this.userId});

  @override
  List<Object?> get props => [
        title,
        isImportant,
        number,
        description,
        createdTime,
        status,
        pin,
        date,
        userId
      ];
}

class UpdateTodo extends CrudEvent {
  final Todo todo;
  final DateTime? completedDate;
  final String? userId;

  const UpdateTodo(
      {required this.todo, this.completedDate, required this.userId});
  @override
  List<Object?> get props => [todo, completedDate, userId];

  // Nested OpenGoogleMapsEvent
  OpenGoogleMapsEvent openGoogleMapsEvent({
    required String location,
  }) {
    return OpenGoogleMapsEvent(location: location);
  }
}

class OpenGoogleMapsEvent extends CrudEvent {
  final String location;

  const OpenGoogleMapsEvent({
    required this.location,
  });

  @override
  List<Object?> get props => [location];
}

class FetchTodos extends CrudEvent {
  final String userId;
  const FetchTodos({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class FetchSpecificTodo extends CrudEvent {
  final int id;
  final String userId;

  const FetchSpecificTodo({required this.id, required this.userId});

  @override
  List<Object?> get props => [id, userId];
}

class DeleteTodo extends CrudEvent {
  final int id;
  final String userId;

  const DeleteTodo({required this.id, required this.userId});

  @override
  List<Object?> get props => [id, userId];
}

class FetchTasksByStatus extends CrudEvent {
  final String status;
  final String userId;
  const FetchTasksByStatus({
    required this.status,
    required this.userId,
  });

  @override
  List<Object?> get props => [status, userId];
}

class FetchTasksByDate extends CrudEvent {
  final DateTime selectedDate;
  final String userId;

  FetchTasksByDate({required this.selectedDate, required this.userId});

  @override
  List<Object?> get props => [selectedDate, userId];
}

class FetchTasksByCompletedDate extends CrudEvent {
  final DateTime selectedDate;
  final String userId;

  FetchTasksByCompletedDate({required this.selectedDate, required this.userId});

  @override
  List<Object?> get props => [selectedDate, userId];
}

class DisplayTasksByCompletedDate extends CrudState {
  final List<Todo> todo;

  const DisplayTasksByCompletedDate({required this.todo});
  @override
  List<Object> get props => [todo];
}
