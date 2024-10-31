part of 'shop_medicines_bloc.dart';

class ShopMedicinesState {
  final List<ShopMedicine> shopMedicines;
  final List<Category> categories;
  final List<OrderItem> cart;
  final bool isLoading;
  final String? error;
  final bool prescriptionUploaded;
  final DeliveryAddress? selectedDeliveryAddress;
  final double? deliveryCharge;
  final String? pendingOrderId;
  final Map<String, dynamic>? paymentDetails;
  final bool orderPlaced;

  ShopMedicinesState({
    required this.shopMedicines,
    required this.categories,
    required this.cart,
    required this.isLoading,
    this.error,
    required this.prescriptionUploaded,
    this.selectedDeliveryAddress,
    this.deliveryCharge,
    this.pendingOrderId,
    this.paymentDetails,
    required this.orderPlaced,
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
      deliveryCharge: null,
      pendingOrderId: null,
      paymentDetails: null,
      orderPlaced: false,
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
    double? deliveryCharge,
    String? pendingOrderId,
    Map<String, dynamic>? paymentDetails,
    bool? orderPlaced,
  }) {
    return ShopMedicinesState(
      shopMedicines: shopMedicines ?? this.shopMedicines,
      categories: categories ?? this.categories,
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      prescriptionUploaded: prescriptionUploaded ?? this.prescriptionUploaded,
      selectedDeliveryAddress:
          selectedDeliveryAddress ?? this.selectedDeliveryAddress,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      pendingOrderId: pendingOrderId ?? this.pendingOrderId,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      orderPlaced: orderPlaced ?? this.orderPlaced,
    );
  }
}
