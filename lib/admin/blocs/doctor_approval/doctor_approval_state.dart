part of 'doctor_approval_bloc.dart';

abstract class DoctorApprovalState {}

class DoctorApprovalInitial extends DoctorApprovalState {}

class DoctorApprovalLoading extends DoctorApprovalState {}

class DoctorApprovalLoaded extends DoctorApprovalState {
  final List<Doctor> doctors;

  DoctorApprovalLoaded(this.doctors);
}

class DoctorApprovalError extends DoctorApprovalState {
  final String message;

  DoctorApprovalError(this.message);
}
