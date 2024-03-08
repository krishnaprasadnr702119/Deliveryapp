part of 'registration_bloc.dart';

abstract class RegistrationEvent {}

class RegistrationSubmitted extends RegistrationEvent {
  final User user;

  RegistrationSubmitted(this.user);
}
