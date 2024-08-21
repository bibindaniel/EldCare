import 'package:eldcare/delivery/presentation/model/delivery_order_model.dart';
import 'package:eldcare/delivery/repository/delivery_order_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

part 'delivery_order_event.dart';
part 'delivery_order_state.dart';

class DeliveryOrderBloc extends Bloc<DeliveryOrderEvent, DeliveryOrderState> {
  final DeliveryOrderRepository repository;

  DeliveryOrderBloc({required this.repository})
      : super(DeliveryOrderInitial()) {
    on<FetchAvailableOrders>(_onFetchAvailableOrders);
    on<AcceptOrder>(_onAcceptOrder);
  }

  void _onFetchAvailableOrders(
      FetchAvailableOrders event, Emitter<DeliveryOrderState> emit) async {
    print('Fetching available orders...'); // Debug print
    emit(DeliveryOrderLoading());
    try {
      final orders = await repository.getAvailableOrders(
          event.deliveryBoyLocation, event.maxDistance);
      print('Fetched ${orders.length} orders'); // Debug print
      print('Orders: $orders'); // Debug print
      emit(DeliveryOrderLoaded(orders));
    } catch (e) {
      print('Error fetching orders: $e'); // Debug print
      emit(DeliveryOrderError('Failed to fetch available orders: $e'));
    }
  }

  void _onAcceptOrder(
      AcceptOrder event, Emitter<DeliveryOrderState> emit) async {
    emit(DeliveryOrderLoading());
    try {
      await repository.acceptOrder(event.orderId, event.deliveryBoyId);
      emit(OrderAccepted());
    } catch (e) {
      emit(DeliveryOrderError('Failed to accept order: $e'));
    }
  }
}
