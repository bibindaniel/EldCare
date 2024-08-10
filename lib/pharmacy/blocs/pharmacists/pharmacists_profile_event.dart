import 'dart:io';

import 'package:eldcare/pharmacy/model/pharmacist.dart';

abstract class PharmacistProfileEvent {}

class LoadPharmacistProfile extends PharmacistProfileEvent {
  final String pharmacistId;
  LoadPharmacistProfile(this.pharmacistId);
}

class UpdatePharmacistProfile extends PharmacistProfileEvent {
  final PharmacistProfile profile;

  UpdatePharmacistProfile(this.profile);
  List<Object> get props => [profile];
}

class UploadPharmacistProfileImage extends PharmacistProfileEvent {
  final String pharmacistId;
  final File image;
  UploadPharmacistProfileImage(this.pharmacistId, this.image);
}
