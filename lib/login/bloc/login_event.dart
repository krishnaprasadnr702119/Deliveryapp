part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final UserCredentials credentials;

  LoginSubmitted(this.credentials);
}

class NavigateToRegistrationPage extends LoginEvent {}
