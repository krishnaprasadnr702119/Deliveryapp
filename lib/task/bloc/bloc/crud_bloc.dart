import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task/data/database_helper.dart';
import '../../models/todo.dart';

part 'crud_event.dart';
part 'crud_state.dart';

class CrudBloc extends Bloc<CrudEvent, CrudState> {
  CrudBloc() : super(CrudInitial()) {
    List<Todo> todos = [];
    on<AddTodo>((event, emit) async {
      await AppDatabase().create(
        Todo(
          createdTime: event.createdTime,
          description: event.description,
          isImportant: event.isImportant,
          number: event.number,
          title: event.title,
          status: 'Pending',
          pin: event.pin,
          date: event.date,
        ),
      );
    });

    on<UpdateTodo>((event, emit) async {
      await AppDatabase().update(
        todo: event.todo.copyWith(status: event.status),
      );
    });

    on<FetchTodos>((event, emit) async {
      todos = await AppDatabase().readAllTodos();
      emit(DisplayTodos(todo: todos));
    });

    on<FetchSpecificTodo>((event, emit) async {
      Todo todo = await AppDatabase().readTodo(id: event.id);
      emit(DisplaySpecificTodo(todo: todo));
    });

    on<DeleteTodo>((event, emit) async {
      await AppDatabase().delete(id: event.id);
      add(const FetchTodos());
    });
  }
}
