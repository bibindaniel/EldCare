part of 'shop_medicines_bloc.dart';

class ShopMedicinesState {
  final List<ShopMedicine> shopMedicines;
  final List<OrderItem> cart;
  final bool isLoading;
  final String? error;

  ShopMedicinesState({
    required this.shopMedicines,
    required this.cart,
    required this.isLoading,
    this.error,
  });

  ShopMedicinesState copyWith({
    List<ShopMedicine>? shopMedicines,
    List<OrderItem>? cart,
    bool? isLoading,
    String? error,
  }) {
    return ShopMedicinesState(
      shopMedicines: shopMedicines ?? this.shopMedicines,
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
