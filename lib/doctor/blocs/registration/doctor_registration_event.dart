import 'dart:io';

abstract class DoctorRegistrationEvent {}

class SubmitDoctorRegistration extends DoctorRegistrationEvent {
  final String userId;
  final String fullName;
  final String mobileNumber;
  final String address;
  final String registrationNumber;
  final String medicalCouncil;
  final String qualification;
  final String specialization;
  final int experience;
  final String hospitalName;
  final String hospitalAddress;
  final String workContact;
  final String workEmail;
  final Map<String, File> documents;

  SubmitDoctorRegistration({
    required this.userId,
    required this.fullName,
    required this.mobileNumber,
    required this.address,
    required this.registrationNumber,
    required this.medicalCouncil,
    required this.qualification,
    required this.specialization,
    required this.experience,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.workContact,
    required this.workEmail,
    required this.documents,
  });
}

class UpdateDocumentFile extends DoctorRegistrationEvent {
  final String documentType;
  final File file;

  UpdateDocumentFile({
    required this.documentType,
    required this.file,
  });
}
