part of 'shop_bloc.dart';

// Events
abstract class ShopEvent extends Equatable {
  const ShopEvent();

  @override
  List<Object> get props => [];
}

class AddShopEvent extends ShopEvent {
  final Shop shop;
  const AddShopEvent(this.shop);
}

class LoadShopsEvent extends ShopEvent {
  final String ownerId;

  const LoadShopsEvent({required this.ownerId});

  @override
  List<Object> get props => [ownerId];
}

class SearchShopsEvent extends ShopEvent {
  final GeoPoint location;
  final double radius;
  const SearchShopsEvent(this.location, this.radius);
}

class UpdateShopEvent extends ShopEvent {
  final Shop shop;

  const UpdateShopEvent(this.shop);

  @override
  List<Object> get props => [shop];
}
