abstract class DoctorRegistrationState {}

class DoctorRegistrationInitial extends DoctorRegistrationState {}

class DoctorRegistrationLoading extends DoctorRegistrationState {}

class DoctorRegistrationSuccess extends DoctorRegistrationState {}

class DoctorRegistrationFailure extends DoctorRegistrationState {
  final String error;

  DoctorRegistrationFailure(this.error);
}

class DocumentUploadProgress extends DoctorRegistrationState {
  final String documentType;
  final double progress;

  DocumentUploadProgress({
    required this.documentType,
    required this.progress,
  });
}
