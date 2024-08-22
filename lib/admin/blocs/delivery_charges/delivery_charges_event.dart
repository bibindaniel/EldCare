part of 'delivery_charges_bloc.dart';

abstract class DeliveryChargesEvent {}

class LoadDeliveryCharges extends DeliveryChargesEvent {}

class SaveDeliveryCharges extends DeliveryChargesEvent {
  final double baseCharge;
  final double perKmCharge;
  final double minimumOrderValue;

  SaveDeliveryCharges({
    required this.baseCharge,
    required this.perKmCharge,
    required this.minimumOrderValue,
  });
}
