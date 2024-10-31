part of 'shop_bloc.dart';

abstract class AdminShopEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AdminLoadShops extends AdminShopEvent {}

class AdminApproveShop extends AdminShopEvent {
  final String shopId;
  final Shop shop;

  AdminApproveShop(this.shopId, this.shop);
}

class AdminRejectShop extends AdminShopEvent {
  final String shopId;
  final Shop shop;

  AdminRejectShop(this.shopId, this.shop);
}
