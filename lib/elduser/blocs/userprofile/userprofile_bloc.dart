import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';
import '../../repository/userprofile_repository.dart';

part 'userprofile_event.dart';
part 'userprofile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserProfileRepository _repository;

  UserProfileBloc(this._repository) : super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<UploadProfileImage>(_onUploadProfileImage);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    try {
      final userProfile = await _repository.getUserProfile(event.userId);
      emit(UserProfileLoaded(userProfile));
    } catch (e) {
      emit(UserProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserProfileLoaded) {
      emit(UserProfileUpdating(currentState.userProfile));
      try {
        await _repository.updateUserProfile(event.userProfile);
        emit(UserProfileLoaded(event.userProfile));
      } catch (e) {
        emit(UserProfileError('Failed to update profile: ${e.toString()}'));
      }
    } else {
      emit(const UserProfileError('Cannot update profile: Invalid state'));
    }
  }

  Future<void> _onUploadProfileImage(
    UploadProfileImage event,
    Emitter<UserProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserProfileLoaded) {
      emit(UserProfileUpdating(currentState.userProfile));
      try {
        final imageUrl =
            await _repository.uploadProfileImage(event.userId, event.image);
        final updatedProfile = currentState.userProfile.copyWith(
          profileImageUrl: imageUrl,
        );
        await _repository.updateUserProfile(updatedProfile);
        emit(UserProfileLoaded(updatedProfile));
      } catch (e) {
        emit(UserProfileError('Failed to upload image: ${e.toString()}'));
      }
    } else {
      emit(
          const UserProfileError('Cannot update profile image: Invalid state'));
    }
  }
}
