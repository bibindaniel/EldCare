part of 'shop_medicines_bloc.dart';

class ShopMedicinesState {
  final List<ShopMedicine> shopMedicines;
  final List<Category> categories;
  final List<OrderItem> cart;
  final bool isLoading;
  final String? error;
  final bool prescriptionUploaded;
  final DeliveryAddress? selectedDeliveryAddress;

  ShopMedicinesState({
    required this.shopMedicines,
    required this.categories,
    required this.cart,
    required this.isLoading,
    this.error,
    required this.prescriptionUploaded,
    this.selectedDeliveryAddress,
  });

  factory ShopMedicinesState.initial() {
    return ShopMedicinesState(
      shopMedicines: [],
      categories: [],
      cart: [],
      isLoading: false,
      error: null,
      prescriptionUploaded: false,
      selectedDeliveryAddress: null,
    );
  }

  ShopMedicinesState copyWith({
    List<ShopMedicine>? shopMedicines,
    List<Category>? categories,
    List<OrderItem>? cart,
    bool? isLoading,
    String? error,
    bool? prescriptionUploaded,
    DeliveryAddress? selectedDeliveryAddress,
  }) {
    return ShopMedicinesState(
      shopMedicines: shopMedicines ?? this.shopMedicines,
      categories: categories ?? this.categories,
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      prescriptionUploaded: prescriptionUploaded ?? this.prescriptionUploaded,
      selectedDeliveryAddress:
          selectedDeliveryAddress ?? this.selectedDeliveryAddress,
    );
  }
}
