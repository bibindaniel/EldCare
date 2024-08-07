part of 'shop_bloc.dart';

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

class ShopInitialState extends ShopState {}

class ShopLoadingState extends ShopState {}

class ShopAddedState extends ShopState {}

class ShopUpdatedState extends ShopState {}

class ShopsLoadedState extends ShopState {
  final List<Shop> shops;

  const ShopsLoadedState(this.shops);

  @override
  List<Object?> get props => [shops];
}

class ShopErrorState extends ShopState {
  final String error;

  const ShopErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
