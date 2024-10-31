import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class CheckLoginStatus extends AuthEvent {}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterEvent(
      {required this.name, required this.email, required this.password});

  @override
  List<Object> get props => [name, email, password];
}

class GoogleSignInEvent extends AuthEvent {}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class SetUserRole extends AuthEvent {
  final String userId;
  final int role;

  const SetUserRole(this.userId, this.role);

  @override
  List<Object> get props => [userId, role];
}

class LogoutEvent extends AuthEvent {}
