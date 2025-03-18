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
      await _doctorRepository.updateDoctorProfile(
        event.doctorId,
        event.updates,
      );
      // Fetch the updated profile and emit it
      final updatedDoctor =
          await _doctorRepository.getDoctorStream(event.doctorId).first;
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
