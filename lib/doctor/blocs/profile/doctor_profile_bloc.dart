import 'package:eldcare/doctor/models/doctor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/doctor/repository/doctor_repository.dart';
import 'doctor_profile_event.dart';
import 'doctor_profile_state.dart';

class DoctorProfileBloc extends Bloc<DoctorProfileEvent, DoctorProfileState> {
  final DoctorRepository _doctorRepository;

  DoctorProfileBloc({
    required DoctorRepository doctorRepository,
  })  : _doctorRepository = doctorRepository,
        super(DoctorProfileInitial()) {
    on<LoadDoctorProfile>(_onLoadProfile);
    on<UpdateDoctorProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadDoctorProfile event,
    Emitter<DoctorProfileState> emit,
  ) async {
    try {
      emit(DoctorProfileLoading());

      // Listen to the stream of doctor data
      await emit.forEach(
        _doctorRepository.getDoctorStream(event.doctorId),
        onData: (Doctor? doctor) {
          if (doctor != null) {
            return DoctorProfileLoaded(doctor);
          } else {
            return DoctorProfileError('Doctor not found');
          }
        },
        onError: (error, stackTrace) {
          return DoctorProfileError(error.toString());
        },
      );
    } catch (e) {
      emit(DoctorProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateDoctorProfile event,
    Emitter<DoctorProfileState> emit,
  ) async {
    try {
      emit(DoctorProfileLoading());

      // If there's a profile image to upload, handle it first
      if (event.profileImageFile != null) {
        final String? imageUrl = await _doctorRepository.uploadProfileImage(
            event.doctorId, event.profileImageFile!);

        if (imageUrl != null) {
          event.updates['profileImageUrl'] = imageUrl;
        }
      }

      await _doctorRepository.updateDoctorProfile(
        event.doctorId,
        event.updates,
      );

      // Fetch the updated doctor and emit success state
      final updatedDoctor =
          await _doctorRepository.getDoctorById(event.doctorId);
      if (updatedDoctor != null) {
        emit(DoctorProfileLoaded(updatedDoctor));
      } else {
        emit(DoctorProfileError('Failed to load updated profile'));
      }
    } catch (e) {
      emit(DoctorProfileError(e.toString()));
    }
  }
}
