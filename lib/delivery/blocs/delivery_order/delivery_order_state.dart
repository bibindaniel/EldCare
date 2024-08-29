part of 'delivery_order_bloc.dart';

abstract class DeliveryOrderState {}

class DeliveryOrderInitial extends DeliveryOrderState {}

class DeliveryOrderLoading extends DeliveryOrderState {}

class DeliveryOrderLoaded extends DeliveryOrderState {
  final List<DeliveryOrderModel> orders;
  final DeliveryOrderModel? currentDelivery;
  final Map<String, int> summary;

  DeliveryOrderLoaded({
    required this.orders,
    this.currentDelivery,
    this.summary = const {'total': 0, 'completed': 0, 'pending': 0},
  });
}

class OrderAccepted extends DeliveryOrderState {
  final DeliveryOrderModel acceptedOrder;

  OrderAccepted(this.acceptedOrder);
}

class DeliveryOrderError extends DeliveryOrderState {
  final String message;

  DeliveryOrderError(this.message);
}

class DeliveryCodeVerificationSuccess extends DeliveryOrderState {}

class DeliveryCodeVerificationFailure extends DeliveryOrderState {}

class DeliveryCanceled extends DeliveryOrderState {}
