import 'dart:io';

import 'package:eldcare/elduser/models/user_profile.dart';
import 'package:eldcare/elduser/repository/userprofile_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'userprofile_event.dart';
part 'userprofile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserProfileRepository _repository;

  UserProfileBloc(this._repository) : super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    // on<UploadProfileImage>(_onUploadProfileImage);
    on<VerifyUser>(_onVerifyUser);
    on<CompleteProfile>(_onCompleteProfile);
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
      print('Error loading user profile: $e'); // Add this line for debugging
      emit(UserProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    try {
      await _repository.updateUserProfile(event.userProfile);
      emit(UserProfileUpdated(event.userProfile));
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  // Future<void> _onUploadProfileImage(
  //   UploadProfileImage event,
  //   Emitter<UserProfileState> emit,
  // ) async {
  //   emit(UserProfileLoading());
  //   try {
  //     final imageUrl = await _repository.uploadProfileImage(event.image);
  //     final currentState = state;
  //     if (currentState is UserProfileLoaded) {
  //       final updatedProfile = currentState.userProfile.copyWith(
  //         // profileImageUrl: imageUrl,
  //       );
  //       await _repository.updateUserProfile(updatedProfile);
  //       emit(UserProfileUpdated(updatedProfile));
  //     } else {
  //       throw Exception('User profile not loaded');
  //     }
  //   } catch (e) {
  //     emit(UserProfileError(e.toString()));
  //   }
  // }

  Future<void> _onVerifyUser(
    VerifyUser event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    try {
      await _repository.verifyUser(event.userId);
      final currentState = state;
      if (currentState is UserProfileLoaded) {
        final updatedProfile = currentState.userProfile.copyWith(
          isVerified: true,
        );
        emit(UserProfileUpdated(updatedProfile));
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onCompleteProfile(
    CompleteProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    try {
      final updatedProfile =
          event.userProfile.copyWith(isProfileComplete: true);
      await _repository.updateUserProfile(updatedProfile);
      emit(UserProfileUpdated(updatedProfile));
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
