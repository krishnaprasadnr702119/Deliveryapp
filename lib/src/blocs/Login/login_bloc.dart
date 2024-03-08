import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:task/src/data/database_helper.dart';
import 'package:task/src/models/user.dart';
import 'package:task/src/models/login_helper.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AppDatabase _appDatabase = AppDatabase();

  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      try {
        final user = await _appDatabase.getUser(
          event.credentials.username,
          event.credentials.password,
        );

        if (user != null) {
          emit(LoginSuccess(user: user));
        } else {
          emit(LoginFailure(error: 'Invalid username or password'));
        }
      } catch (e) {
        emit(LoginFailure(error: e.toString()));
      }
    });
  }
}
