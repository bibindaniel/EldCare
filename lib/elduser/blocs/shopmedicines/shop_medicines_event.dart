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
  AddToCart(this.shopMedicine);
}

class RemoveFromCart extends ShopMedicinesEvent {
  final ShopMedicine shopMedicine;
  RemoveFromCart(this.shopMedicine);
}

class PlaceOrder extends ShopMedicinesEvent {
  final String userId;
  final String shopId;
  PlaceOrder(this.userId, this.shopId);
}
