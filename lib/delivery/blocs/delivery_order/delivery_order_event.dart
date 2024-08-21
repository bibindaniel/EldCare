part of 'delivery_order_bloc.dart';

abstract class DeliveryOrderEvent {}

class FetchAvailableOrders extends DeliveryOrderEvent {
  final GeoPoint deliveryBoyLocation;
  final double maxDistance;

  FetchAvailableOrders(this.deliveryBoyLocation, this.maxDistance);
}

class AcceptOrder extends DeliveryOrderEvent {
  final String orderId;
  final String deliveryBoyId;

  AcceptOrder(this.orderId, this.deliveryBoyId);
}
