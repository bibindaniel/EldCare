part of 'pharmacist_navigation_bloc.dart';

enum NavigationItem { shops, inventory, orders, analytics, profile }

class PharmacistNavigationState extends Equatable {
  final NavigationItem currentItem;

  const PharmacistNavigationState({required this.currentItem});

  @override
  List<Object> get props => [currentItem];
}
