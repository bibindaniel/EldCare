import 'package:eldcare/delivery/model/delivery_order_model.dart';
import 'package:eldcare/delivery/repository/delivery_order_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'delivery_order_event.dart';
part 'delivery_order_state.dart';

class DeliveryOrderBloc extends Bloc<DeliveryOrderEvent, DeliveryOrderState> {
  final DeliveryOrderRepository repository;
  List<DeliveryOrderModel> _availableOrders = [];
  DeliveryOrderModel? _currentDelivery;

  DeliveryOrderBloc({required this.repository})
      : super(DeliveryOrderInitial()) {
    on<FetchAvailableOrders>(_onFetchAvailableOrders);
    on<AcceptOrder>(_onAcceptOrder);
    on<FetchCurrentDelivery>(_onFetchCurrentDelivery);
    on<FetchDeliverySummary>(_onFetchDeliverySummary);
  }

  void _onFetchAvailableOrders(
      FetchAvailableOrders event, Emitter<DeliveryOrderState> emit) async {
    emit(DeliveryOrderLoading());
    try {
      _availableOrders = await repository.getAvailableOrders(
          event.deliveryBoyLocation, event.maxDistance);
      emit(DeliveryOrderLoaded(
          orders: _availableOrders, currentDelivery: _currentDelivery));
    } catch (e) {
      emit(DeliveryOrderError('Failed to fetch available orders: $e'));
    }
  }

  void _onAcceptOrder(
      AcceptOrder event, Emitter<DeliveryOrderState> emit) async {
    emit(DeliveryOrderLoading());
    try {
      final updatedOrder =
          await repository.acceptOrder(event.orderId, event.deliveryPersonId);
      _currentDelivery = updatedOrder;
      _availableOrders.removeWhere((order) => order.id == updatedOrder.id);
      emit(DeliveryOrderLoaded(
          orders: _availableOrders, currentDelivery: _currentDelivery));
    } catch (e) {
      emit(DeliveryOrderError('Failed to accept order: $e'));
    }
  }

  void _onFetchCurrentDelivery(
      FetchCurrentDelivery event, Emitter<DeliveryOrderState> emit) async {
    try {
      _currentDelivery =
          await repository.getCurrentDelivery(event.deliveryPersonId);
      emit(DeliveryOrderLoaded(
          orders: _availableOrders, currentDelivery: _currentDelivery));
    } catch (e) {
      emit(DeliveryOrderError('Failed to fetch current delivery: $e'));
    }
  }

  void _onFetchDeliverySummary(
      FetchDeliverySummary event, Emitter<DeliveryOrderState> emit) async {
    try {
      final summary =
          await repository.getDeliverySummary(event.deliveryPersonId);
      if (state is DeliveryOrderLoaded) {
        final currentState = state as DeliveryOrderLoaded;
        emit(DeliveryOrderLoaded(
          orders: currentState.orders,
          currentDelivery: currentState.currentDelivery,
          summary: summary,
        ));
      }
    } catch (e) {
      emit(DeliveryOrderError('Failed to fetch delivery summary: $e'));
    }
  }
}
