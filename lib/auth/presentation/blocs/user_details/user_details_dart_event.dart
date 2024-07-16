part of 'user_details_dart_bloc.dart';

abstract class UserDetailsDartEvent extends Equatable {
  const UserDetailsDartEvent();

  @override
  List<Object> get props => [];
}

class SubmitUserDetails extends UserDetailsDartEvent {
  final UserDetails userDetails;

  const SubmitUserDetails(this.userDetails);
  @override
  List<Object> get props => [userDetails];
}
