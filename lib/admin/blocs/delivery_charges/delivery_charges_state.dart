part of 'delivery_charges_bloc.dart';

abstract class DeliveryChargesState {}

class DeliveryChargesInitial extends DeliveryChargesState {}

class DeliveryChargesLoading extends DeliveryChargesState {}

class DeliveryChargesLoaded extends DeliveryChargesState {
  final DeliveryChargesModel charges;

  DeliveryChargesLoaded(this.charges);
}

class DeliveryChargesSaved extends DeliveryChargesState {}

class DeliveryChargesError extends DeliveryChargesState {
  final String message;

  DeliveryChargesError(this.message);
}
