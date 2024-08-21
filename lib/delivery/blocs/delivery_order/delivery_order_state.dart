part of 'delivery_order_bloc.dart';

abstract class DeliveryOrderState {}

class DeliveryOrderInitial extends DeliveryOrderState {}

class DeliveryOrderLoading extends DeliveryOrderState {}

class DeliveryOrderLoaded extends DeliveryOrderState {
  final List<DeliveryOrderModel> orders;

  DeliveryOrderLoaded(this.orders);
}

class OrderAccepted extends DeliveryOrderState {}

class DeliveryOrderError extends DeliveryOrderState {
  final String message;

  DeliveryOrderError(this.message);
}
