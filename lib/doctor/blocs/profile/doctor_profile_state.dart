import 'package:eldcare/doctor/models/doctor.dart';

abstract class DoctorProfileState {}

class DoctorProfileInitial extends DoctorProfileState {}

class DoctorProfileLoading extends DoctorProfileState {}

class DoctorProfileLoaded extends DoctorProfileState {
  final Doctor doctor;

  DoctorProfileLoaded(this.doctor);
}

class DoctorProfileError extends DoctorProfileState {
  final String message;

  DoctorProfileError(this.message);
}
