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
  final String userId;
  final File image;

  const UploadProfileImage(this.userId, this.image);

  @override
  List<Object> get props => [userId, image];
}
