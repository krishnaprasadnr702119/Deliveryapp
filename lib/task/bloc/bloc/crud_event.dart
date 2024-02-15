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

  const AddTodo({
    required this.title,
    required this.isImportant,
    required this.number,
    required this.description,
    required this.createdTime,
    required this.status,
    required this.pin,
    required this.date,
  });

  @override
  List<Object?> get props =>
      [title, isImportant, number, description, createdTime, status, pin, date];
}

class UpdateTodo extends CrudEvent {
  final Todo todo;
  final DateTime? completedDate;

  const UpdateTodo({required this.todo, this.completedDate});

  @override
  List<Object?> get props => [todo, completedDate];

  get status => null;

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
  const FetchTodos();

  @override
  List<Object?> get props => [];
}

class FetchSpecificTodo extends CrudEvent {
  final int id;

  const FetchSpecificTodo({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteTodo extends CrudEvent {
  final int id;

  const DeleteTodo({required this.id});

  @override
  List<Object?> get props => [id];
}

class FetchTasksByStatus extends CrudEvent {
  final String status;

  const FetchTasksByStatus({required this.status});

  @override
  List<Object?> get props => [status];
}

class FetchTasksByDate extends CrudEvent {
  final DateTime selectedDate;

  const FetchTasksByDate({required this.selectedDate});

  @override
  List<Object> get props => [selectedDate];
}
