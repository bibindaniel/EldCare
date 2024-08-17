part of 'inventory_bloc.dart';

abstract class InventoryEvent {}

class LoadInventory extends InventoryEvent {
  final String shopId;
  LoadInventory(this.shopId);
}

class AddInventoryBatch extends InventoryEvent {
  final InventoryBatch batch;
  AddInventoryBatch(this.batch);
}

class UpdateInventoryBatch extends InventoryEvent {
  final InventoryBatch batch;
  UpdateInventoryBatch(this.batch);
}

class DeleteInventoryBatch extends InventoryEvent {
  final String batchId;
  final String shopId;
  DeleteInventoryBatch(this.batchId, this.shopId);
}

class SearchInventory extends InventoryEvent {
  final String query;
  final String shopId;
  SearchInventory(this.query, this.shopId);
}
