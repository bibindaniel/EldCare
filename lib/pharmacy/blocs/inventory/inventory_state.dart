part of 'inventory_bloc.dart';

abstract class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryBatch> batches;
  InventoryLoaded(this.batches);
}

class InventoryOperationSuccess extends InventoryState {
  final String message;
  InventoryOperationSuccess(this.message);
}

class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
}
