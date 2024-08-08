import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'pharmacist_navigation_event.dart';
part 'pharmacist_navigation_state.dart';

class PharmacistNavigationBloc
    extends Bloc<PharmacistNavigationEvent, PharmacistNavigationState> {
  PharmacistNavigationBloc()
      : super(const PharmacistNavigationState(
            currentItem: NavigationItem.shops)) {
    on<NavigateToShops>(_onNavigateToShops);
    on<NavigateToInventory>(_onNavigateToInventory);
    on<NavigateToOrders>(_onNavigateToOrders);
    on<NavigateToAnalytics>(_onNavigateToAnalytics);
    on<NavigateToProfile>(_onNavigateToProfile);
  }

  void _onNavigateToShops(
      NavigateToShops event, Emitter<PharmacistNavigationState> emit) {
    emit(const PharmacistNavigationState(currentItem: NavigationItem.shops));
  }

  void _onNavigateToInventory(
      NavigateToInventory event, Emitter<PharmacistNavigationState> emit) {
    emit(
        const PharmacistNavigationState(currentItem: NavigationItem.inventory));
  }

  void _onNavigateToOrders(
      NavigateToOrders event, Emitter<PharmacistNavigationState> emit) {
    emit(const PharmacistNavigationState(currentItem: NavigationItem.orders));
  }

  void _onNavigateToAnalytics(
      NavigateToAnalytics event, Emitter<PharmacistNavigationState> emit) {
    emit(
        const PharmacistNavigationState(currentItem: NavigationItem.analytics));
  }

  void _onNavigateToProfile(
      NavigateToProfile event, Emitter<PharmacistNavigationState> emit) {
    emit(const PharmacistNavigationState(currentItem: NavigationItem.profile));
  }
}
