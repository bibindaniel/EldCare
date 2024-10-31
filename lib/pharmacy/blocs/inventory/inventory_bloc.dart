import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/pharmacy/repository/inventory_repository.dart';
import 'package:eldcare/pharmacy/model/inventory_batch.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _inventoryRepository;

  InventoryBloc(
      {required InventoryRepository inventoryRepository,
      required InventoryRepository repository})
      : _inventoryRepository = inventoryRepository,
        super(InventoryInitial()) {
    on<LoadInventory>(_onLoadInventory);
    on<AddInventoryBatch>(_onAddInventoryBatch);
    on<UpdateInventoryBatch>(_onUpdateInventoryBatch);
    on<DeleteInventoryBatch>(_onDeleteInventoryBatch);
    on<SearchInventory>(_onSearchInventory);
  }
  void _onLoadInventory(
      LoadInventory event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    try {
      await emit.forEach(
        _inventoryRepository.getInventoryBatchesForShop(event.shopId),
        onData: (List<InventoryBatch> batches) => InventoryLoaded(batches),
        onError: (error, stackTrace) => InventoryError(error.toString()),
      );
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  void _onAddInventoryBatch(
      AddInventoryBatch event, Emitter<InventoryState> emit) async {
    final currentState = state;
    if (currentState is InventoryLoaded) {
      try {
        await _inventoryRepository.addInventoryBatch(event.batch);
        final updatedBatches = List<InventoryBatch>.from(currentState.batches)
          ..add(event.batch);
        emit(InventoryLoaded(updatedBatches));
        emit(InventoryOperationSuccess('Inventory batch added successfully'));
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    }
  }

  void _onUpdateInventoryBatch(
      UpdateInventoryBatch event, Emitter<InventoryState> emit) async {
    final currentState = state;
    if (currentState is InventoryLoaded) {
      try {
        await _inventoryRepository.updateInventoryBatch(event.batch);
        final updatedBatches = currentState.batches
            .map((batch) => batch.id == event.batch.id ? event.batch : batch)
            .toList();
        emit(InventoryLoaded(updatedBatches));
        emit(InventoryOperationSuccess('Inventory batch updated successfully'));
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    }
  }

  void _onDeleteInventoryBatch(
      DeleteInventoryBatch event, Emitter<InventoryState> emit) async {
    final currentState = state;
    if (currentState is InventoryLoaded) {
      try {
        await _inventoryRepository.deleteInventoryBatch(
            event.batchId, event.shopId);
        final updatedBatches = currentState.batches
            .where((batch) => batch.id != event.batchId)
            .toList();
        emit(InventoryLoaded(updatedBatches));
        emit(InventoryOperationSuccess('Inventory batch deleted successfully'));
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    }
  }

  void _onSearchInventory(
      SearchInventory event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    try {
      final batches = await _inventoryRepository.searchInventoryBatches(
          event.query, event.shopId);
      emit(InventoryLoaded(batches));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
}
