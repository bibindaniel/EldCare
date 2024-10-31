import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/shoplisting.dart';
import 'package:eldcare/elduser/repository/shoplisting_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'verified_shop_listing_event.dart';
part 'verified_shop_listing_state.dart';

class VerifiedShopListingBloc
    extends Bloc<VerifiedShopListingEvent, VerifiedShopListingState> {
  final VerifiedShopListingRepository repository;

  VerifiedShopListingBloc({required this.repository})
      : super(VerifiedShopListingInitial()) {
    on<LoadVerifiedShops>(_onLoadVerifiedShops);
    on<SearchVerifiedShops>(_onSearchVerifiedShops);
    on<LoadNearbyVerifiedShops>(_onLoadNearbyVerifiedShops);
  }

  void _onLoadVerifiedShops(
      LoadVerifiedShops event, Emitter<VerifiedShopListingState> emit) async {
    emit(VerifiedShopListingLoading());
    try {
      await emit.forEach(
        repository.getVerifiedShops(),
        onData: (List<VerifiedShopListing> shops) =>
            VerifiedShopListingLoaded(shops),
        onError: (error, stackTrace) =>
            VerifiedShopListingError(error.toString()),
      );
    } catch (e) {
      emit(VerifiedShopListingError(e.toString()));
    }
  }

  void _onSearchVerifiedShops(
      SearchVerifiedShops event, Emitter<VerifiedShopListingState> emit) async {
    emit(VerifiedShopListingLoading());
    try {
      final shops = await repository.searchVerifiedShops(event.query);
      emit(VerifiedShopListingLoaded(shops));
    } catch (e) {
      emit(VerifiedShopListingError(e.toString()));
    }
  }

  void _onLoadNearbyVerifiedShops(LoadNearbyVerifiedShops event,
      Emitter<VerifiedShopListingState> emit) async {
    emit(VerifiedShopListingLoading());
    try {
      final shops = await repository.getNearbyVerifiedShops(
          event.userLocation, event.radiusInKm);
      emit(VerifiedShopListingLoaded(shops));
    } catch (e) {
      emit(VerifiedShopListingError(e.toString()));
    }
  }
}
