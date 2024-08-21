import 'package:equatable/equatable.dart';

enum DeliveryNavigationItem { home, orders, profile }

class DeliveryNavigationState extends Equatable {
  final DeliveryNavigationItem currentItem;

  const DeliveryNavigationState(
      {this.currentItem = DeliveryNavigationItem.home});

  @override
  List<Object> get props => [currentItem];
}
