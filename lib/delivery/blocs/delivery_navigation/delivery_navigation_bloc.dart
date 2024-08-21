import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/delivery/blocs/delivery_navigation/delivery_navigation_event.dart';
import 'package:eldcare/delivery/blocs/delivery_navigation/delivery_navigation_state.dart';

class DeliveryNavigationBloc
    extends Bloc<DeliveryNavigationEvent, DeliveryNavigationState> {
  DeliveryNavigationBloc() : super(const DeliveryNavigationState()) {
    on<NavigateToDeliveryHome>(_onNavigateToHome);
    on<NavigateToDeliveryOrders>(_onNavigateToOrders);
    on<NavigateToDeliveryProfile>(_onNavigateToProfile);
  }

  void _onNavigateToHome(
      NavigateToDeliveryHome event, Emitter<DeliveryNavigationState> emit) {
    emit(const DeliveryNavigationState(
        currentItem: DeliveryNavigationItem.home));
  }

  void _onNavigateToOrders(
      NavigateToDeliveryOrders event, Emitter<DeliveryNavigationState> emit) {
    emit(const DeliveryNavigationState(
        currentItem: DeliveryNavigationItem.orders));
  }

  void _onNavigateToProfile(
      NavigateToDeliveryProfile event, Emitter<DeliveryNavigationState> emit) {
    emit(const DeliveryNavigationState(
        currentItem: DeliveryNavigationItem.profile));
  }
}
