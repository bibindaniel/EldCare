// lib/elduser/blocs/order/order_bloc.dart
import 'package:eldcare/elduser/models/order.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/elduser/blocs/order/order_event.dart';
import 'package:eldcare/elduser/blocs/order/order_state.dart';
import 'package:eldcare/elduser/repository/order_repo.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  OrderBloc(this._orderRepository) : super(OrderInitial()) {
    on<FetchOrders>(_onFetchOrders);
  }

  void _onFetchOrders(FetchOrders event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      // Use the stream method from your existing repository
      await emit.forEach(
        _orderRepository.getOrdersForUser(event.userId),
        onData: (List<MedicineOrder> orders) => OrderLoaded(orders),
        onError: (error, stackTrace) =>
            OrderError('Failed to fetch orders: $error'),
      );
    } catch (e) {
      emit(OrderError('Failed to fetch orders: $e'));
    }
  }
}
