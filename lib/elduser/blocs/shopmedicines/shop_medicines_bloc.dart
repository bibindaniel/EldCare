import 'dart:io';
import 'package:eldcare/admin/repository/delivery_repo.dart';
import 'package:eldcare/elduser/models/delivary_address.dart';
import 'package:eldcare/elduser/models/order.dart';
import 'package:eldcare/elduser/models/shop_medicine.dart';
import 'package:eldcare/elduser/repository/order_repo.dart';
import 'package:eldcare/elduser/repository/shop_medicine_repo.dart';
import 'package:eldcare/pharmacy/model/category.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

part 'shop_medicines_event.dart';
part 'shop_medicines_state.dart';

class ShopMedicinesBloc extends Bloc<ShopMedicinesEvent, ShopMedicinesState> {
  final ShopMedicineRepository shopMedicineRepository;
  final OrderRepository orderRepository;
  final DeliveryChargesRepository deliveryChargesRepository;

  ShopMedicinesBloc({
    required this.shopMedicineRepository,
    required this.orderRepository,
    required this.deliveryChargesRepository,
  }) : super(ShopMedicinesState.initial()) {
    on<LoadShopMedicines>(_onLoadShopMedicines);
    on<SearchShopMedicines>(_onSearchShopMedicines);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<PlaceOrder>(_onPlaceOrder);
    on<UpdateShopMedicines>(_onUpdateShopMedicines);
    on<SelectDeliveryAddress>(_onSelectDeliveryAddress);
    on<CalculateDeliveryCharge>(_onCalculateDeliveryCharge);
    on<InitiatePayment>(_onInitiatePayment);
    on<UpdateOrderPaymentStatus>(_onUpdateOrderPaymentStatus);
  }

  Future<void> _onLoadShopMedicines(
      LoadShopMedicines event, Emitter<ShopMedicinesState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final shopMedicinesStream =
          shopMedicineRepository.getShopMedicinesStream(event.shopId);
      final categoriesStream =
          shopMedicineRepository.getCategoriesStream(event.shopId);

      final combinedStream = Rx.combineLatest2(
        shopMedicinesStream,
        categoriesStream,
        (List<ShopMedicine> medicines, List<Category> categories) =>
            (medicines, categories),
      );

      await emit.forEach(
        combinedStream,
        onData: (data) {
          final medicines = data.$1;
          final categories = data.$2;
          return state.copyWith(
            shopMedicines: medicines,
            categories: categories,
            isLoading: false,
          );
        },
        onError: (error, stackTrace) {
          return state.copyWith(error: error.toString(), isLoading: false);
        },
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onSearchShopMedicines(
      SearchShopMedicines event, Emitter<ShopMedicinesState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final medicines = await shopMedicineRepository.searchShopMedicines(
          event.query, event.shopId);
      emit(state.copyWith(isLoading: false, shopMedicines: medicines));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onAddToCart(AddToCart event, Emitter<ShopMedicinesState> emit) {
    final updatedCart = List<OrderItem>.from(state.cart);
    final existingItemIndex = updatedCart
        .indexWhere((item) => item.medicineId == event.shopMedicine.id);
    if (existingItemIndex != -1) {
      updatedCart[existingItemIndex] = OrderItem(
        medicineId: event.shopMedicine.id,
        medicineName: event.shopMedicine.medicineName,
        quantity: updatedCart[existingItemIndex].quantity + event.quantity,
        price: event.shopMedicine.price,
      );
    } else {
      updatedCart.add(OrderItem(
        medicineId: event.shopMedicine.id,
        medicineName: event.shopMedicine.medicineName,
        quantity: event.quantity,
        price: event.shopMedicine.price,
      ));
    }
    emit(state.copyWith(cart: updatedCart));
  }

  void _onRemoveFromCart(
      RemoveFromCart event, Emitter<ShopMedicinesState> emit) {
    final updatedCart = List<OrderItem>.from(state.cart);
    updatedCart
        .removeWhere((item) => item.medicineId == event.orderItem.medicineId);
    emit(state.copyWith(cart: updatedCart));
  }

  void _onUpdateShopMedicines(
      UpdateShopMedicines event, Emitter<ShopMedicinesState> emit) {
    emit(state.copyWith(shopMedicines: event.medicines, isLoading: false));
  }

  void _onSelectDeliveryAddress(
    SelectDeliveryAddress event,
    Emitter<ShopMedicinesState> emit,
  ) {
    emit(state.copyWith(selectedDeliveryAddress: event.deliveryAddress));
  }

  void _onPlaceOrder(PlaceOrder event, Emitter<ShopMedicinesState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      String? prescriptionUrl;
      if (event.prescriptionFile != null) {
        // Upload prescription to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child(
            'prescriptions/${DateTime.now().toIso8601String()}_${event.prescriptionFile!.path.split('/').last}');
        final uploadTask = storageRef.putFile(event.prescriptionFile!);
        final snapshot = await uploadTask.whenComplete(() {});
        prescriptionUrl = await snapshot.ref.getDownloadURL();
      }

      final order = MedicineOrder(
        id: '', // Firestore will generate this
        userId: event.userId,
        shopId: event.shopId,
        items: state.cart,
        totalAmount: state.cart
                .fold(0.0, (sum, item) => sum + (item.price * item.quantity)) +
            (state.deliveryCharge ?? 0),
        status: 'paid',
        createdAt: DateTime.now(),
        prescriptionUrl: prescriptionUrl,
        deliveryAddress: event.deliveryAddress,
        phoneNumber: event.phoneNumber,
        deliveryCharge: state.deliveryCharge,
        paymentId: event.paymentId,
      );

      final orderId = await orderRepository.createOrder(order);
      emit(state.copyWith(
        isLoading: false,
        pendingOrderId: orderId,
        prescriptionUploaded: prescriptionUrl != null,
        cart: [], // Clear the cart after successful order placement
        orderPlaced: true,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onInitiatePayment(
      InitiatePayment event, Emitter<ShopMedicinesState> emit) async {
    try {
      final paymentDetails =
          await orderRepository.getPaymentDetails(state.pendingOrderId!);
      emit(state.copyWith(paymentDetails: paymentDetails));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to initiate payment: $e'));
    }
  }

  void _onUpdateOrderPaymentStatus(
      UpdateOrderPaymentStatus event, Emitter<ShopMedicinesState> emit) async {
    try {
      await orderRepository.updateOrderPaymentStatus(
        orderId: event.orderId,
        paymentId: event.paymentId,
        status: event.status,
      );

      if (event.status == 'success') {
        emit(state.copyWith(
          cart: [],
          pendingOrderId: null,
          paymentDetails: null,
          orderPlaced: true,
        ));
      } else {
        emit(state.copyWith(
          error: 'Payment failed',
          pendingOrderId: null,
          paymentDetails: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update order status: $e'));
    }
  }

  void _onCalculateDeliveryCharge(
    CalculateDeliveryCharge event,
    Emitter<ShopMedicinesState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final charges = await deliveryChargesRepository.getDeliveryCharges();
      final shopLocation =
          await shopMedicineRepository.getShopLocation(event.shopId);

      final distance = Geolocator.distanceBetween(
            shopLocation.latitude,
            shopLocation.longitude,
            event.deliveryAddress.address.location!.latitude,
            event.deliveryAddress.address.location!.longitude,
          ) /
          1000; // Convert meters to kilometers

      double deliveryCharge =
          charges.baseCharge + (charges.perKmCharge * distance);

      double cartTotal = state.cart
          .fold(0.0, (sum, item) => sum + (item.price * item.quantity));

      if (cartTotal >= charges.minimumOrderValue) {
        deliveryCharge = 0;
      }

      emit(state.copyWith(
        deliveryCharge: deliveryCharge,
        isLoading: false,
        selectedDeliveryAddress: event.deliveryAddress,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to calculate delivery charge: $e',
        isLoading: false,
      ));
    }
  }
}
