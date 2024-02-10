// lib/forgetpassword/screen/bloc/forgetpassword_state.dart

part of 'forgetpassword_bloc.dart';

abstract class ForgetPasswordState {}

class ForgetPasswordInitial extends ForgetPasswordState {}

class ForgetPasswordSuccess extends ForgetPasswordState {}

class ForgetPasswordFailure extends ForgetPasswordState {
  final String error;

  ForgetPasswordFailure({required this.error});
}
