part of 'verified_shop_listing_bloc.dart';

abstract class VerifiedShopListingState extends Equatable {
  const VerifiedShopListingState();

  @override
  List<Object> get props => [];
}

class VerifiedShopListingInitial extends VerifiedShopListingState {}

class VerifiedShopListingLoading extends VerifiedShopListingState {}

class VerifiedShopListingLoaded extends VerifiedShopListingState {
  final List<VerifiedShopListing> shops;

  const VerifiedShopListingLoaded(this.shops);

  @override
  List<Object> get props => [shops];
}

class VerifiedShopListingError extends VerifiedShopListingState {
  final String message;

  const VerifiedShopListingError(this.message);

  @override
  List<Object> get props => [message];
}
