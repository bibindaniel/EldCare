import 'package:eldcare/pharmacy/model/pharmacist_order.dart';
import 'package:equatable/equatable.dart';

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

class UpdatePharmacistOrderStatus extends PharmacistOrderEvent {
  final String orderId;
  final OrderStatus newStatus;

  const UpdatePharmacistOrderStatus(this.orderId, this.newStatus);

  @override
  List<Object> get props => [orderId, newStatus];
}
