import 'package:equatable/equatable.dart';

abstract class DeliveryNavigationEvent extends Equatable {
  const DeliveryNavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigateToDeliveryHome extends DeliveryNavigationEvent {}

class NavigateToDeliveryOrders extends DeliveryNavigationEvent {}

class NavigateToDeliveryProfile extends DeliveryNavigationEvent {}
