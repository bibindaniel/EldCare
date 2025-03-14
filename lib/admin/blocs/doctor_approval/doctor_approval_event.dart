part of 'doctor_approval_bloc.dart';

abstract class DoctorApprovalEvent {}

class LoadPendingDoctors extends DoctorApprovalEvent {}

class ApproveDoctor extends DoctorApprovalEvent {
  final String doctorId;
  final Doctor doctor;

  ApproveDoctor(this.doctorId, this.doctor);
}

class RejectDoctor extends DoctorApprovalEvent {
  final String doctorId;
  final Doctor doctor;

  RejectDoctor(this.doctorId, this.doctor);
}
