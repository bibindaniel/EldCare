import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:eldcare/pharmacy/repository/shop.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'shop_event.dart';
part 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final ShopRepository _shopRepository;

  ShopBloc({required ShopRepository shopRepository})
      : _shopRepository = shopRepository,
        super(ShopInitialState()) {
    on<AddShopEvent>(_onAddShop);
    on<LoadShopsEvent>(_onLoadShops);
    on<SearchShopsEvent>(_onSearchShops);
    on<UpdateShopEvent>(_onUpdateShop); // Add the update event handler
  }

  Future<void> _onAddShop(AddShopEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoadingState());
    try {
      await _shopRepository.addShop(event.shop);
      emit(ShopAddedState());
    } catch (e) {
      emit(ShopErrorState(e.toString()));
    }
  }

  void _onLoadShops(LoadShopsEvent event, Emitter<ShopState> emit) async {
    print('Loading shops for owner: ${event.ownerId}');
    emit(ShopLoadingState());

    await emit.forEach(
      _shopRepository.getShops(event.ownerId),
      onData: (List<Shop> shops) {
        print('Loaded ${shops.length} shops');
        return ShopsLoadedState(shops);
      },
      onError: (error, stackTrace) {
        print('Error loading shops: $error');
        return ShopErrorState(error.toString());
      },
    );
  }

  Future<void> _onSearchShops(
      SearchShopsEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoadingState());
    try {
      final shops = await _shopRepository.searchShopsByLocation(
          event.location, event.radius);
      emit(ShopsLoadedState(shops));
    } catch (e) {
      emit(ShopErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateShop(
      UpdateShopEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoadingState());
    try {
      await _shopRepository.updateShop(event.shop);
      emit(ShopUpdatedState());
    } catch (e) {
      emit(ShopErrorState(e.toString()));
    }
  }
}
