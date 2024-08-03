part of 'userprofile_bloc.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadUserProfile extends UserProfileEvent {
  final String userId;

  const LoadUserProfile(this.userId);

  @override
  List<Object> get props => [userId];
}

class UpdateUserProfile extends UserProfileEvent {
  final UserProfile userProfile;

  const UpdateUserProfile(this.userProfile);

  @override
  List<Object> get props => [userProfile];
}

class UploadProfileImage extends UserProfileEvent {
  final File image;

  const UploadProfileImage(this.image);

  @override
  List<Object> get props => [image];
}

class VerifyUser extends UserProfileEvent {
  final String userId;

  const VerifyUser(this.userId);

  @override
  List<Object> get props => [userId];
}

class CompleteProfile extends UserProfileEvent {
  final UserProfile userProfile;

  const CompleteProfile(this.userProfile);
}
