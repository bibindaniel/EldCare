part of 'shop_bloc.dart';

abstract class AdminShopState extends Equatable {
  @override
  List<Object> get props => [];
}

class AdminShopInitial extends AdminShopState {}

class AdminShopLoading extends AdminShopState {}

class AdminShopLoaded extends AdminShopState {
  final List<Shop> shops;
  final List<Shop> pendingShops;

  AdminShopLoaded({required this.shops, required this.pendingShops});

  @override
  List<Object> get props => [shops, pendingShops];
}

class AdminShopError extends AdminShopState {
  final String message;

  AdminShopError(this.message);

  @override
  List<Object> get props => [message];
}
