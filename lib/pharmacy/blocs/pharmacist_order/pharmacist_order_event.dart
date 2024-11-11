import 'package:equatable/equatable.dart';
import 'package:eldcare/pharmacy/model/pharmacist_order.dart';

abstract class PharmacistOrderEvent extends Equatable {
  const PharmacistOrderEvent();

  @override
  List<Object> get props => [];
}

class LoadPharmacistOrders extends PharmacistOrderEvent {
  final String shopId;

  const LoadPharmacistOrders(this.shopId);

  @override
  List<Object> get props => [shopId];
}

class LoadRecentOrders extends PharmacistOrderEvent {
  final String shopId;

  const LoadRecentOrders(this.shopId);

  @override
  List<Object> get props => [shopId];
}

class UpdatePharmacistOrderStatus extends PharmacistOrderEvent {
  final String orderId;
  final OrderStatus newStatus;

  const UpdatePharmacistOrderStatus(this.orderId, this.newStatus);

  @override
  List<Object> get props => [orderId, newStatus];
}

class OrdersUpdated extends PharmacistOrderEvent {
  final List<PharmacistOrderModel> orders;

  const OrdersUpdated(this.orders);

  @override
  List<Object> get props => [orders];
}

class OrdersError extends PharmacistOrderEvent {
  final String error;

  const OrdersError(this.error);

  @override
  List<Object> get props => [error];
}
