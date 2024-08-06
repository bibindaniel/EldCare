import 'dart:io';

import 'package:eldcare/pharmacy/model/pharmacist.dart';
import 'package:equatable/equatable.dart';

abstract class PharmacistProfileEvent extends Equatable {
  const PharmacistProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadPharmacistProfile extends PharmacistProfileEvent {
  final String pharmacistId;

  const LoadPharmacistProfile(this.pharmacistId);

  @override
  List<Object> get props => [pharmacistId];
}

class UpdatePharmacistProfile extends PharmacistProfileEvent {
  final PharmacistProfile pharmacistProfile;

  const UpdatePharmacistProfile(this.pharmacistProfile);

  @override
  List<Object> get props => [pharmacistProfile];
}

class UploadPharmacistProfileImage extends PharmacistProfileEvent {
  final File image;

  const UploadPharmacistProfileImage(this.image);

  @override
  List<Object> get props => [image];
}

class VerifyPharmacist extends PharmacistProfileEvent {
  final String pharmacistId;

  const VerifyPharmacist(this.pharmacistId);

  @override
  List<Object> get props => [pharmacistId];
}

class CompletePharmacistProfile extends PharmacistProfileEvent {
  final PharmacistProfile pharmacistProfile;

  const CompletePharmacistProfile(this.pharmacistProfile);

  @override
  List<Object> get props => [pharmacistProfile];
}
