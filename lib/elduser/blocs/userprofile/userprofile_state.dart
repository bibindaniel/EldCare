part of 'userprofile_bloc.dart';

abstract class UserProfileState extends Equatable {
  final UserProfile? userProfile;

  const UserProfileState({this.userProfile});

  @override
  List<Object?> get props => [userProfile];
}

class UserProfileInitial extends UserProfileState {
  const UserProfileInitial() : super(userProfile: null);
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading({UserProfile? userProfile})
      : super(userProfile: userProfile);
}

class UserProfileLoaded extends UserProfileState {
  @override
  final UserProfile userProfile;

  const UserProfileLoaded(this.userProfile) : super(userProfile: userProfile);
}

class UserProfileUpdating extends UserProfileState {
  const UserProfileUpdating(UserProfile userProfile)
      : super(userProfile: userProfile);
}

class UserProfileUpdated extends UserProfileState {
  const UserProfileUpdated(UserProfile userProfile)
      : super(userProfile: userProfile);
}

class UserProfileError extends UserProfileState {
  final String error;

  const UserProfileError(this.error, {UserProfile? userProfile})
      : super(userProfile: userProfile);

  @override
  List<Object?> get props => [error, userProfile];
}
