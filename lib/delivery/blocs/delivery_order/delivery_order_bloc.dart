import 'package:eldcare/delivery/model/delivery_order_model.dart';
import 'package:eldcare/delivery/repository/delivery_order_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

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
    on<VerifyDeliveryCode>(_onVerifyDeliveryCode);
    on<CancelDelivery>(_onCancelDelivery);
    on<SendTestEmail>(_onSendTestEmail);
    on<FetchOrderHistory>(_onFetchOrderHistory);
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

  void _onVerifyDeliveryCode(
      VerifyDeliveryCode event, Emitter<DeliveryOrderState> emit) async {
    emit(DeliveryOrderLoading());
    try {
      bool isValid =
          await repository.verifyDeliveryCode(event.orderId, event.enteredCode);
      if (isValid) {
        await repository.markOrderAsDelivered(event.orderId);
        _currentDelivery = null;
        emit(DeliveryCodeVerificationSuccess());

        // Get the current location
        Position position = await Geolocator.getCurrentPosition();
        GeoPoint currentLocation =
            GeoPoint(position.latitude, position.longitude);

        // After successful verification, fetch updated orders and current delivery
        add(FetchAvailableOrders(
            deliveryBoyLocation: currentLocation,
            maxDistance: 10.0 // You can adjust this value as needed
            ));
        add(FetchCurrentDelivery(deliveryPersonId: event.deliveryPersonId));
      } else {
        emit(DeliveryCodeVerificationFailure());
      }
    } catch (e) {
      emit(DeliveryOrderError('Failed to verify delivery code: $e'));
    }
  }

  void _onCancelDelivery(
      CancelDelivery event, Emitter<DeliveryOrderState> emit) async {
    emit(DeliveryOrderLoading());
    try {
      await repository.cancelDelivery(event.orderId);
      _currentDelivery = null;
      emit(DeliveryCanceled());

      // Fetch updated orders and current delivery
      Position position = await Geolocator.getCurrentPosition();
      GeoPoint currentLocation =
          GeoPoint(position.latitude, position.longitude);

      add(FetchAvailableOrders(
          deliveryBoyLocation: currentLocation, maxDistance: 10.0));
      add(FetchCurrentDelivery(deliveryPersonId: event.deliveryPersonId));
    } catch (e) {
      emit(DeliveryOrderError('Failed to cancel delivery: $e'));
    }
  }

  void _onSendTestEmail(
      SendTestEmail event, Emitter<DeliveryOrderState> emit) async {
    emit(DeliveryOrderLoading());
    try {
      await repository.sendTestEmail();
      emit(TestEmailSent());
    } catch (e) {
      emit(DeliveryOrderError('Failed to send test email: $e'));
    }
  }

  void _onFetchOrderHistory(
      FetchOrderHistory event, Emitter<DeliveryOrderState> emit) async {
    try {
      final orderHistory =
          await repository.getOrderHistory(event.deliveryPersonId);
      if (state is DeliveryOrderLoaded) {
        final currentState = state as DeliveryOrderLoaded;
        emit(DeliveryOrderLoaded(
          orders: currentState.orders,
          currentDelivery: currentState.currentDelivery,
          summary: currentState.summary,
          orderHistory: orderHistory,
        ));
      }
    } catch (e) {
      emit(DeliveryOrderError('Failed to fetch order history: $e'));
    }
  }
}
