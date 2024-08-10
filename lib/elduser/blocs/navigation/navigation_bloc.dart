import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc()
      : super(const NavigationState(currentItem: NavigationItem.home)) {
    on<NavigateToHome>((event, emit) =>
        emit(const NavigationState(currentItem: NavigationItem.home)));
    on<NavigateToSchedule>((event, emit) =>
        emit(const NavigationState(currentItem: NavigationItem.schedule)));
    on<NavigateToShop>((event, emit) =>
        emit(const NavigationState(currentItem: NavigationItem.shop)));
    on<NavigateToAppointment>((event, emit) =>
        emit(const NavigationState(currentItem: NavigationItem.appointment)));
  }
}
