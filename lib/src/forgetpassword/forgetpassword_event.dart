part of 'forgetpassword_bloc.dart';

abstract class ForgetPasswordEvent {}

class ForgetPasswordSubmitted extends ForgetPasswordEvent {
  final User user;

  ForgetPasswordSubmitted(this.user);
}
