import 'dart:async';
import 'package:eldcare/pharmacy/repository/pharmacistorderrepositry.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_event.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_state.dart';

class PharmacistOrderBloc
    extends Bloc<PharmacistOrderEvent, PharmacistOrderState> {
  final PharmacistOrderRepository pharmacistOrderRepository;
  StreamSubscription? _ordersSubscription;

  PharmacistOrderBloc({required this.pharmacistOrderRepository})
      : super(PharmacistOrderInitial()) {
    on<LoadPharmacistOrders>(_onLoadPharmacistOrders);
    on<UpdatePharmacistOrderStatus>(_onUpdatePharmacistOrderStatus);
    on<OrdersUpdated>(_onOrdersUpdated);
  }

  void _onLoadPharmacistOrders(
    LoadPharmacistOrders event,
    Emitter<PharmacistOrderState> emit,
  ) async {
    emit(PharmacistOrderLoading());
    await _ordersSubscription?.cancel();
    _ordersSubscription =
        pharmacistOrderRepository.getOrdersStream(event.shopId).listen(
              (orders) => add(OrdersUpdated(orders)),
              onError: (error) => add(OrdersError(error.toString())),
            );
  }

  void _onOrdersUpdated(
    OrdersUpdated event,
    Emitter<PharmacistOrderState> emit,
  ) {
    emit(PharmacistOrderLoaded(event.orders));
  }

  void _onUpdatePharmacistOrderStatus(
    UpdatePharmacistOrderStatus event,
    Emitter<PharmacistOrderState> emit,
  ) async {
    try {
      await pharmacistOrderRepository.updateOrderStatus(
          event.orderId, event.newStatus);
      // The stream will automatically emit the updated orders
    } catch (e) {
      emit(PharmacistOrderError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
