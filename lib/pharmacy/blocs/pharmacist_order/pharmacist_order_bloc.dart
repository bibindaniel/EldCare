import 'package:eldcare/pharmacy/repository/pharmacistorderrepositry.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_event.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_state.dart';

class PharmacistOrderBloc
    extends Bloc<PharmacistOrderEvent, PharmacistOrderState> {
  final PharmacistOrderRepository pharmacistOrderRepository;

  PharmacistOrderBloc(
      {required this.pharmacistOrderRepository,
      required PharmacistOrderRepository orderRepository})
      : super(PharmacistOrderInitial()) {
    on<LoadPharmacistOrders>(_onLoadPharmacistOrders);
    on<UpdatePharmacistOrderStatus>(_onUpdatePharmacistOrderStatus);
  }

  Future<void> _onLoadPharmacistOrders(
    LoadPharmacistOrders event,
    Emitter<PharmacistOrderState> emit,
  ) async {
    emit(PharmacistOrderLoading());
    try {
      final orders = await pharmacistOrderRepository.getOrders(event.shopId);
      emit(PharmacistOrderLoaded(orders));
    } catch (e) {
      if (e is FirebaseException && e.code == 'failed-precondition') {
        emit(const PharmacistOrderError(
            'The database index is still being built. Please try again in a few minutes.'));
      } else {
        emit(PharmacistOrderError(e.toString()));
      }
    }
  }

  Future<void> _refreshOrders(
      String shopId, Emitter<PharmacistOrderState> emit) async {
    try {
      final updatedOrders = await pharmacistOrderRepository.getOrders(shopId);
      emit(PharmacistOrderLoaded(updatedOrders));
    } catch (e) {
      emit(PharmacistOrderError(e.toString()));
    }
  }

  Future<void> _onUpdatePharmacistOrderStatus(
    UpdatePharmacistOrderStatus event,
    Emitter<PharmacistOrderState> emit,
  ) async {
    try {
      await pharmacistOrderRepository.updateOrderStatus(
          event.orderId, event.newStatus);
      if (state is PharmacistOrderLoaded) {
        final currentState = state as PharmacistOrderLoaded;
        await _refreshOrders(currentState.orders.first.shopId, emit);
      }
    } catch (e) {
      emit(PharmacistOrderError(e.toString()));
    }
  }
}
