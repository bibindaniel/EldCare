part of 'users_bloc.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchUsers extends UserEvent {}

class FetchUserById extends UserEvent {
  final String userId;

  FetchUserById(this.userId);

  @override
  List<Object> get props => [userId];
}
