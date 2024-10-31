part of 'shop_medicines_bloc.dart';

abstract class ShopMedicinesEvent {}

class LoadShopMedicines extends ShopMedicinesEvent {
  final String shopId;
  LoadShopMedicines(this.shopId);
}

class SearchShopMedicines extends ShopMedicinesEvent {
  final String query;
  final String shopId;
  SearchShopMedicines(this.query, this.shopId);
}

class AddToCart extends ShopMedicinesEvent {
  final ShopMedicine shopMedicine;
  final int quantity;

  AddToCart(this.shopMedicine, this.quantity);
}

class RemoveFromCart extends ShopMedicinesEvent {
  final OrderItem orderItem;

  RemoveFromCart(this.orderItem);
}

class SelectDeliveryAddress extends ShopMedicinesEvent {
  final DeliveryAddress deliveryAddress;

  SelectDeliveryAddress(this.deliveryAddress);
}

class PlaceOrder extends ShopMedicinesEvent {
  final String userId;
  final String shopId;
  final DeliveryAddress deliveryAddress;
  final String phoneNumber;
  final File? prescriptionFile;
  final String paymentId;

  PlaceOrder({
    required this.userId,
    required this.shopId,
    required this.deliveryAddress,
    required this.phoneNumber,
    this.prescriptionFile,
    required this.paymentId,
  });
}

class UpdateShopMedicines extends ShopMedicinesEvent {
  final List<ShopMedicine> medicines;

  UpdateShopMedicines(this.medicines);
}

class CalculateDeliveryCharge extends ShopMedicinesEvent {
  final String shopId;
  final DeliveryAddress deliveryAddress;

  CalculateDeliveryCharge(
      {required this.shopId, required this.deliveryAddress});
}

class InitiatePayment extends ShopMedicinesEvent {}

class UpdateOrderPaymentStatus extends ShopMedicinesEvent {
  final String orderId;
  final String paymentId;
  final String status;

  UpdateOrderPaymentStatus({
    required this.orderId,
    required this.paymentId,
    required this.status,
  });
}
