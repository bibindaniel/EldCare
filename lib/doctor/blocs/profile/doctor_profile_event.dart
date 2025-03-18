abstract class DoctorProfileEvent {}

class LoadDoctorProfile extends DoctorProfileEvent {
  final String doctorId;

  LoadDoctorProfile(this.doctorId);
}

class UpdateDoctorProfile extends DoctorProfileEvent {
  final String doctorId;
  final Map<String, dynamic> updates;

  UpdateDoctorProfile({
    required this.doctorId,
    required this.updates,
  });
}
