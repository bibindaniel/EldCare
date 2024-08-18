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
  final File? prescriptionFile;
  final DeliveryAddress deliveryAddress;
  final String phoneNumber;
  PlaceOrder({
    required this.userId,
    required this.shopId,
    this.prescriptionFile,
    required this.deliveryAddress,
    required this.phoneNumber,
  });
}

class UpdateShopMedicines extends ShopMedicinesEvent {
  final List<ShopMedicine> medicines;

  UpdateShopMedicines(this.medicines);
}
