import 'dart:io';
import 'package:eldcare/elduser/models/order.dart';
import 'package:eldcare/elduser/models/shop_medicine.dart';
import 'package:eldcare/elduser/repository/order_repo.dart';
import 'package:eldcare/elduser/repository/shop_medicine_repo.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'shop_medicines_event.dart';
part 'shop_medicines_state.dart';

class ShopMedicinesBloc extends Bloc<ShopMedicinesEvent, ShopMedicinesState> {
  final ShopMedicineRepository shopMedicineRepository;
  final OrderRepository orderRepository;

  ShopMedicinesBloc({
    required this.shopMedicineRepository,
    required this.orderRepository,
  }) : super(
            ShopMedicinesState(shopMedicines: [], cart: [], isLoading: false)) {
    print(
        'ShopMedicinesBloc created with initial cart size: ${state.cart.length}');
    on<LoadShopMedicines>(_onLoadShopMedicines);
    on<SearchShopMedicines>(_onSearchShopMedicines);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<PlaceOrder>(_onPlaceOrder);
  }

  void _onLoadShopMedicines(
      LoadShopMedicines event, Emitter<ShopMedicinesState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      print('Loading medicines for shop: ${event.shopId}'); // Debug print
      await emit.forEach(
        shopMedicineRepository.getShopMedicinesStream(event.shopId),
        onData: (List<ShopMedicine> shopMedicines) {
          print('Received ${shopMedicines.length} medicines'); // Debug print
          return state.copyWith(
            shopMedicines: shopMedicines,
            isLoading: false,
          );
        },
      );
    } catch (e) {
      print('Error loading medicines: $e'); // Debug print
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onSearchShopMedicines(
      SearchShopMedicines event, Emitter<ShopMedicinesState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final shopMedicines = await shopMedicineRepository.searchShopMedicines(
          event.query, event.shopId);
      emit(state.copyWith(shopMedicines: shopMedicines, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onAddToCart(AddToCart event, Emitter<ShopMedicinesState> emit) {
    final updatedCart = List<OrderItem>.from(state.cart);
    final existingItemIndex = updatedCart
        .indexWhere((item) => item.medicineId == event.shopMedicine.medicineId);
    if (existingItemIndex != -1) {
      updatedCart[existingItemIndex] = OrderItem(
        medicineId: event.shopMedicine.medicineId,
        medicineName: event.shopMedicine.medicineName!,
        quantity: updatedCart[existingItemIndex].quantity + event.quantity,
        price: event.shopMedicine.price,
      );
    } else {
      updatedCart.add(OrderItem(
        medicineId: event.shopMedicine.medicineId,
        medicineName: event.shopMedicine.medicineName!,
        quantity: event.quantity,
        price: event.shopMedicine.price,
      ));
    }
    print(
        'AddToCart event - Medicine: ${event.shopMedicine.medicineName}, Quantity: ${event.quantity}');
    print('AddToCart event - Updated cart size: ${updatedCart.length}');
    emit(state.copyWith(cart: updatedCart));
  }

  void _onRemoveFromCart(
      RemoveFromCart event, Emitter<ShopMedicinesState> emit) {
    final updatedCart = List<OrderItem>.from(state.cart);
    updatedCart
        .removeWhere((item) => item.medicineId == event.orderItem.medicineId);
    emit(state.copyWith(cart: updatedCart));
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
            .fold(0, (sum, item) => sum + (item.price * item.quantity)),
        status: 'pending',
        createdAt: DateTime.now(),
        prescriptionUrl: prescriptionUrl,
      );

      await orderRepository.createOrder(order);
      emit(state.copyWith(
          isLoading: false,
          cart: [],
          prescriptionUploaded: prescriptionUrl != null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
