import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_event.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/pharmacy/repository/pharmacist_profile_repository.dart';

class PharmacistProfileBloc
    extends Bloc<PharmacistProfileEvent, PharmacistProfileState> {
  final PharmacistProfileRepository _repository;

  PharmacistProfileBloc(this._repository) : super(PharmacistProfileInitial()) {
    on<LoadPharmacistProfile>(_onLoadPharmacistProfile);
    on<UpdatePharmacistProfile>(_onUpdatePharmacistProfile);
    on<UploadPharmacistProfileImage>(_onUploadPharmacistProfileImage);
  }

  Future<void> _onLoadPharmacistProfile(
    LoadPharmacistProfile event,
    Emitter<PharmacistProfileState> emit,
  ) async {
    emit(PharmacistProfileLoading());
    try {
      final pharmacistProfile =
          await _repository.getPharmacistProfile(event.pharmacistId);
      emit(PharmacistProfileLoaded(pharmacistProfile));
    } catch (e) {
      emit(PharmacistProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePharmacistProfile(
    UpdatePharmacistProfile event,
    Emitter<PharmacistProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is PharmacistProfileLoaded) {
      emit(PharmacistProfileUpdating(currentState.pharmacistProfile));
      try {
        await _repository.updatePharmacistProfile(event.profile);
        emit(PharmacistProfileLoaded(event.profile));
      } catch (e) {
        emit(PharmacistProfileError(
            'Failed to update profile: ${e.toString()}'));
      }
    } else {
      emit(
          const PharmacistProfileError('Cannot update profile: Invalid state'));
    }
  }

  Future<void> _onUploadPharmacistProfileImage(
    UploadPharmacistProfileImage event,
    Emitter<PharmacistProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is PharmacistProfileLoaded) {
      emit(PharmacistProfileUpdating(currentState.pharmacistProfile));
      try {
        final imageUrl = await _repository.uploadProfileImage(
            event.pharmacistId, event.image);
        final updatedProfile = currentState.pharmacistProfile.copyWith(
          profileImageUrl: imageUrl,
        );
        await _repository.updatePharmacistProfile(updatedProfile);
        emit(PharmacistProfileLoaded(updatedProfile));
      } catch (e) {
        emit(PharmacistProfileError('Failed to upload image: ${e.toString()}'));
      }
    } else {
      emit(
          PharmacistProfileError('Cannot update profile image: Invalid state'));
    }
  }
}
