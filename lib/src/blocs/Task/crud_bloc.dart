import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task/src/data/database_helper.dart';
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
          userId: event.userId,
        ),
      );
    });

    on<UpdateTodo>((event, emit) async {
      await AppDatabase().update(
        todo: event.todo.copyWith(
          userId: event.userId,
        ),
      );
    });

    on<FetchTodos>((event, emit) async {
      todos = await AppDatabase().readAllTodos(userId: event.userId);
      emit(DisplayTodos(todo: todos));
    });

    on<FetchSpecificTodo>((event, emit) async {
      Todo todo = await AppDatabase().readTodo(id: event.id);
      emit(DisplaySpecificTodo(todo: todo));
    });

    on<DeleteTodo>((event, emit) async {
      await AppDatabase().delete(id: event.id);
      add(FetchTodos(userId: event.userId));
    });

    on<FetchTasksByStatus>((event, emit) async {
      List<Todo> tasks = await AppDatabase()
          .readTodosByStatus(event.status, userId: event.userId);
      emit(DisplayTodos(todo: tasks));
    });

    on<FetchTasksByDate>((event, emit) async {
      List<Todo> tasks = await AppDatabase()
          .readTodosByDate(event.selectedDate, userId: event.userId);
      emit(DisplayTodos(todo: tasks));
    });
    on<FetchTasksByCompletedDate>((event, emit) async {
      List<Todo> tasks = await AppDatabase()
          .readTodosByCompletedDate(event.selectedDate, userId: event.userId);
      emit(DisplayTasksByCompletedDate(todo: tasks));
    });

    on<SaveImageToDbEvent>((event, emit) async {
      try {
        await AppDatabase().saveImagePathToDb(event.todoId, event.imagePath);
        emit(ImageSavedToDbState());
      } catch (e) {
        emit(ImageSaveToDbErrorState(error: e.toString()));
      }
    });
  }
}
