import 'package:eldcare/doctor/models/doctor.dart';

abstract class DoctorProfileEvent {}

class LoadDoctorProfile extends DoctorProfileEvent {
  final String doctorId;

  LoadDoctorProfile(this.doctorId);
}

class UpdateDoctorProfile extends DoctorProfileEvent {
  final Doctor doctor;

  UpdateDoctorProfile(this.doctor);
}
