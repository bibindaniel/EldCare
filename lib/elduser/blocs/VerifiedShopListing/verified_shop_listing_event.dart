part of 'verified_shop_listing_bloc.dart';

abstract class VerifiedShopListingEvent extends Equatable {
  const VerifiedShopListingEvent();

  @override
  List<Object> get props => [];
}

class LoadVerifiedShops extends VerifiedShopListingEvent {}

class SearchVerifiedShops extends VerifiedShopListingEvent {
  final String query;

  const SearchVerifiedShops(this.query);

  @override
  List<Object> get props => [query];
}

class LoadNearbyVerifiedShops extends VerifiedShopListingEvent {
  final GeoPoint userLocation;
  final double radiusInKm;

  const LoadNearbyVerifiedShops(this.userLocation, this.radiusInKm);

  @override
  List<Object> get props => [userLocation, radiusInKm];
}
