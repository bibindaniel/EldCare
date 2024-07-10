part of 'user_details_dart_bloc.dart';

abstract class UserDetailsDartState extends Equatable {
  const UserDetailsDartState();

  @override
  List<Object> get props => [];
}

final class UserDetailsDartInitial extends UserDetailsDartState {}

final class UserDetailsDartLoading extends UserDetailsDartState {}

final class UserDetailsDartSuccess extends UserDetailsDartState {
  final UserDetails userDetails;

  const UserDetailsDartSuccess(this.userDetails);
  @override
  List<Object> get props => [userDetails];
}

final class UserDetailsDartFailure extends UserDetailsDartState {
  final String error;

  const UserDetailsDartFailure(this.error);
  @override
  List<Object> get props => [error];
}
