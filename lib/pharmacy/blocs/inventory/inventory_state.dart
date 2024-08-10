import 'package:eldcare/pharmacy/model/inventory_batch.dart';

abstract class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryBatch> batches;
  InventoryLoaded(this.batches);
}

class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
}
