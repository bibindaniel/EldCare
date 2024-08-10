import 'package:eldcare/pharmacy/blocs/inventory/inventory_event.dart';
import 'package:eldcare/pharmacy/model/inventory_batch.dart';
import 'package:eldcare/pharmacy/repository/inventory_repository.dart';
import 'package:eldcare/pharmacy/blocs/inventory/inventory_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository repository;
  Stream<List<InventoryBatch>>? _inventoryStream;
  String? _currentShopId;

  InventoryBloc({required this.repository}) : super(InventoryInitial()) {
    on<LoadInventory>(_onLoadInventory);
    on<AddInventoryBatch>(_onAddInventoryBatch);
    on<UpdateInventoryBatch>(_onUpdateInventoryBatch);
    on<DeleteInventoryBatch>(_onDeleteInventoryBatch);
    on<SearchInventory>(_onSearchInventory);
  }

  void _startInventoryStream(String shopId) {
    if (_currentShopId != shopId) {
      _currentShopId = shopId;
      _inventoryStream = repository.getInventoryBatchesForShop(shopId);
      _inventoryStream?.listen((batches) {
        add(LoadInventory(shopId));
      });
    }
  }

  void _onLoadInventory(
      LoadInventory event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    try {
      _startInventoryStream(event.shopId);
      final batches =
          await repository.getInventoryBatchesForShop(event.shopId).first;
      emit(InventoryLoaded(batches));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onAddInventoryBatch(
      AddInventoryBatch event, Emitter<InventoryState> emit) async {
    try {
      await repository.addInventoryBatch(event.batch);
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onUpdateInventoryBatch(
      UpdateInventoryBatch event, Emitter<InventoryState> emit) async {
    try {
      await repository.updateInventoryBatch(event.batch);
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onDeleteInventoryBatch(
      DeleteInventoryBatch event, Emitter<InventoryState> emit) async {
    try {
      await repository.deleteInventoryBatch(event.batchId);
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onSearchInventory(
      SearchInventory event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    try {
      if (event.query.isEmpty) {
        final batches =
            await repository.getInventoryBatchesForShop(event.shopId).first;
        emit(InventoryLoaded(batches));
      } else {
        final batches =
            await repository.searchInventoryBatches(event.query, event.shopId);
        emit(InventoryLoaded(batches));
      }
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
}
