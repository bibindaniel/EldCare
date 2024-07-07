part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class CheckLoginStatus extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final String email;
  final String password;

  LoggedIn({required this.email, required this.password});
}

class RegisterEvent extends AuthEvent {
  final UserModel user;

  RegisterEvent({required this.user});
}

class LogOutEvent extends AuthEvent {}
