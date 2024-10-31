import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigateToHome extends NavigationEvent {}

class NavigateToSchedule extends NavigationEvent {}

class NavigateToShop extends NavigationEvent {}

class NavigateToAppointment extends NavigationEvent {}
