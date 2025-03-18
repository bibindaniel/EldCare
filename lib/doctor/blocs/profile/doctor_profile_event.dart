import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class DoctorProfileEvent extends Equatable {
  const DoctorProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadDoctorProfile extends DoctorProfileEvent {
  final String doctorId;

  const LoadDoctorProfile(this.doctorId);

  @override
  List<Object> get props => [doctorId];
}

class UpdateDoctorProfile extends DoctorProfileEvent {
  final String doctorId;
  final Map<String, dynamic> updates;
  final File? profileImageFile;

  const UpdateDoctorProfile({
    required this.doctorId,
    required this.updates,
    this.profileImageFile,
  });

  @override
  List<Object?> get props => [doctorId, updates, profileImageFile];
}
