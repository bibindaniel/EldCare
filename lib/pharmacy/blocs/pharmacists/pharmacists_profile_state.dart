import 'package:eldcare/pharmacy/model/pharmacist.dart';
import 'package:equatable/equatable.dart';

abstract class PharmacistProfileState extends Equatable {
  const PharmacistProfileState();

  @override
  List<Object> get props => [];
}

class PharmacistProfileInitial extends PharmacistProfileState {}

class PharmacistProfileLoading extends PharmacistProfileState {}

class PharmacistProfileLoaded extends PharmacistProfileState {
  final PharmacistProfile pharmacistProfile;

  const PharmacistProfileLoaded(this.pharmacistProfile);

  @override
  List<Object> get props => [pharmacistProfile];
}

class PharmacistProfileUpdating extends PharmacistProfileState {
  final PharmacistProfile pharmacistProfile;

  const PharmacistProfileUpdating(this.pharmacistProfile);

  @override
  List<Object> get props => [pharmacistProfile];
}

class PharmacistProfileError extends PharmacistProfileState {
  final String error;

  const PharmacistProfileError(this.error);

  @override
  List<Object> get props => [error];
}
