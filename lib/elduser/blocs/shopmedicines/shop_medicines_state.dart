part of 'shop_medicines_bloc.dart';

class ShopMedicinesState {
  final List<ShopMedicine> shopMedicines;
  final List<Category> categories;
  final List<OrderItem> cart;
  final bool isLoading;
  final String? error;
  final bool prescriptionUploaded;

  ShopMedicinesState({
    required this.shopMedicines,
    required this.categories,
    required this.cart,
    required this.isLoading,
    this.error,
    required this.prescriptionUploaded,
  });

  // Update the factory constructor for the initial state
  factory ShopMedicinesState.initial() {
    return ShopMedicinesState(
      shopMedicines: [],
      categories: [],
      cart: [],
      isLoading: false,
      error: null,
      prescriptionUploaded: false,
    );
  }

  ShopMedicinesState copyWith({
    List<ShopMedicine>? shopMedicines,
    List<Category>? categories,
    List<OrderItem>? cart,
    bool? isLoading,
    String? error,
    bool? prescriptionUploaded,
  }) {
    return ShopMedicinesState(
      shopMedicines: shopMedicines ?? this.shopMedicines,
      categories: categories ?? this.categories,
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      prescriptionUploaded: prescriptionUploaded ?? this.prescriptionUploaded,
    );
  }
}
