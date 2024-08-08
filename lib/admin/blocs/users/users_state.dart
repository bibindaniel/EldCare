part of 'users_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserProfile> elderlyUsers;
  final List<PharmacistProfile> pharmacists;

  const UserLoaded({required this.elderlyUsers, required this.pharmacists});

  @override
  List<Object> get props => [elderlyUsers, pharmacists];
}

class UserDetailLoaded extends UserState {
  final UserProfile user;

  const UserDetailLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}
