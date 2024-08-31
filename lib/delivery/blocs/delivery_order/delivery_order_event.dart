part of 'delivery_order_bloc.dart';

abstract class DeliveryOrderEvent {}

class FetchAvailableOrders extends DeliveryOrderEvent {
  final GeoPoint deliveryBoyLocation;
  final double maxDistance;

  FetchAvailableOrders(
      {required this.deliveryBoyLocation, required this.maxDistance});
}

class AcceptOrder extends DeliveryOrderEvent {
  final String orderId;
  final String deliveryPersonId;

  AcceptOrder(this.orderId, this.deliveryPersonId);
}

class FetchCurrentDelivery extends DeliveryOrderEvent {
  final String deliveryPersonId;

  FetchCurrentDelivery({required this.deliveryPersonId});
}

class FetchDeliverySummary extends DeliveryOrderEvent {
  final String deliveryPersonId;

  FetchDeliverySummary(this.deliveryPersonId);
}

class VerifyDeliveryCode extends DeliveryOrderEvent {
  final String orderId;
  final String enteredCode;
  final String deliveryPersonId;

  VerifyDeliveryCode(this.orderId, this.enteredCode, this.deliveryPersonId);
}

class CancelDelivery extends DeliveryOrderEvent {
  final String orderId;
  final String deliveryPersonId;

  CancelDelivery(this.orderId, this.deliveryPersonId);
}

class SendTestEmail extends DeliveryOrderEvent {}

class FetchOrderHistory extends DeliveryOrderEvent {
  final String deliveryPersonId;

  FetchOrderHistory(this.deliveryPersonId);
}
