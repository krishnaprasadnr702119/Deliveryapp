// lib/forgetpassword/screen/bloc/forgetpassword_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:task/data/database_helper.dart';
import 'package:task/models/user.dart';

part 'forgetpassword_event.dart';
part 'forgetpassword_state.dart';

class ForgetPasswordBloc
    extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  final _appDatabase = AppDatabase();

  ForgetPasswordBloc() : super(ForgetPasswordInitial()) {
    on<ForgetPasswordSubmitted>(_mapForgetPasswordSubmittedToState);
  }

  FutureOr<void> _mapForgetPasswordSubmittedToState(
    ForgetPasswordSubmitted event,
    Emitter<ForgetPasswordState> emit,
  ) async {
    try {
      final existingUser = await _appDatabase.getUserByEmail(event.user.email);

      if (existingUser != null) {
        // User exists, update the password
        final updatedUser =
            existingUser.copyWith(password: event.user.password);

        // Use the correct method to save the updated user and reset the password
        await _appDatabase.saveUser(updatedUser, resetPassword: true);

        emit(ForgetPasswordSuccess());
      } else {
        // User does not exist, handle accordingly
        emit(ForgetPasswordFailure(
            error: "User not found with the provided email."));
      }
    } catch (e) {
      emit(ForgetPasswordFailure(error: "Failed to reset password: $e"));
    }
  }
}
