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
    on<VerifyPharmacist>(_onVerifyPharmacist);
    on<CompletePharmacistProfile>(_onCompletePharmacistProfile);
  }

  Future<void> _onLoadPharmacistProfile(
    LoadPharmacistProfile event,
    Emitter<PharmacistProfileState> emit,
  ) async {
    emit(PharmacistProfileLoading());
    try {
      final pharmacistProfile =
          await _repository.getPharmacistProfile(event.pharmacistId);
      if (pharmacistProfile != null) {
        emit(PharmacistProfileLoaded(pharmacistProfile));
      } else {
        emit(PharmacistProfileError('Pharmacist profile not found'));
      }
    } catch (e) {
      print('Error loading pharmacist profile: $e');
      emit(PharmacistProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePharmacistProfile(
    UpdatePharmacistProfile event,
    Emitter<PharmacistProfileState> emit,
  ) async {
    emit(PharmacistProfileLoading());
    try {
      await _repository.updatePharmacistProfile(event.pharmacistProfile);
      final updatedProfile =
          await _repository.getPharmacistProfile(event.pharmacistProfile.id);
      if (updatedProfile != null) {
        emit(PharmacistProfileUpdated(updatedProfile));
      } else {
        emit(PharmacistProfileError('Failed to retrieve updated profile'));
      }
    } catch (e) {
      emit(PharmacistProfileError(e.toString()));
    }
  }

  Future<void> _onUploadPharmacistProfileImage(
    UploadPharmacistProfileImage event,
    Emitter<PharmacistProfileState> emit,
  ) async {
    emit(PharmacistProfileLoading());
    try {
      final imageUrl =
          await _repository.uploadPharmacistProfileImage(event.image);
      final currentState = state;
      if (currentState is PharmacistProfileLoaded) {
        final updatedProfile = currentState.pharmacistProfile.copyWith(
          profileImageUrl: imageUrl,
        );
        await _repository.updatePharmacistProfile(updatedProfile);
        emit(PharmacistProfileUpdated(updatedProfile));
      } else {
        throw Exception('Pharmacist profile not loaded');
      }
    } catch (e) {
      emit(PharmacistProfileError(e.toString()));
    }
  }

  Future<void> _onVerifyPharmacist(
    VerifyPharmacist event,
    Emitter<PharmacistProfileState> emit,
  ) async {
    emit(PharmacistProfileLoading());
    try {
      await _repository.verifyPharmacist(event.pharmacistId);
      final updatedProfile =
          await _repository.getPharmacistProfile(event.pharmacistId);
      if (updatedProfile != null) {
        emit(PharmacistProfileUpdated(updatedProfile));
      } else {
        emit(PharmacistProfileError('Failed to retrieve updated profile'));
      }
    } catch (e) {
      emit(PharmacistProfileError(e.toString()));
    }
  }

  Future<void> _onCompletePharmacistProfile(
    CompletePharmacistProfile event,
    Emitter<PharmacistProfileState> emit,
  ) async {
    emit(PharmacistProfileLoading());
    try {
      final updatedProfile =
          event.pharmacistProfile.copyWith(isProfileComplete: true);
      await _repository.updatePharmacistProfile(updatedProfile);
      emit(PharmacistProfileUpdated(updatedProfile));
    } catch (e) {
      emit(PharmacistProfileError(e.toString()));
    }
  }
}
