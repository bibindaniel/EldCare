part of 'pharmacist_navigation_bloc.dart';

abstract class PharmacistNavigationEvent extends Equatable {
  const PharmacistNavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigateToShops extends PharmacistNavigationEvent {}

class NavigateToInventory extends PharmacistNavigationEvent {}

class NavigateToOrders extends PharmacistNavigationEvent {}

class NavigateToAnalytics extends PharmacistNavigationEvent {}

class NavigateToProfile extends PharmacistNavigationEvent {}
