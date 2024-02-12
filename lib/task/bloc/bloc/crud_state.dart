part of 'crud_bloc.dart';

abstract class CrudState extends Equatable {
  const CrudState();
}

class CrudInitial extends CrudState {
  @override
  List<Object> get props => [];
}

class DisplayTodos extends CrudState {
  final List<Todo> todo;

  const DisplayTodos({required this.todo});
  @override
  List<Object> get props => [todo];
}

class DisplaySpecificTodo extends CrudState {
  final Todo todo;

  const DisplaySpecificTodo({required this.todo});
  @override
  List<Object> get props => [todo];
}

class DisplayFilteredTodos extends CrudState {
  final List<Todo> filteredTodos;

  const DisplayFilteredTodos({required this.filteredTodos});
  @override
  List<Object> get props => [filteredTodos];
}

class GoogleMapsOpened extends CrudState {
  final String location;

  const GoogleMapsOpened({required this.location});
  @override
  List<Object> get props => [location];
}
