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

class ImageSavedToDbState extends CrudState {
  @override
  List<Object> get props => [];
}

class ImageSaveToDbErrorState extends CrudState {
  final String error;

  const ImageSaveToDbErrorState({required this.error});

  @override
  List<Object> get props => [error];
}

class DeletedTodos extends CrudState {
  final List<Todo> deletedTodo;

  DeletedTodos(this.deletedTodo);

  @override
  List<Object?> get props => [deletedTodo];
}
