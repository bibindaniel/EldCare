import 'package:equatable/equatable.dart';

enum NavigationItem { home, schedule, shop, appointment }

class NavigationState extends Equatable {
  final NavigationItem currentItem;

  const NavigationState({required this.currentItem});

  @override
  List<Object> get props => [currentItem];
}
