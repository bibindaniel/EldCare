import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/pharmacy/model/inventory_batch.dart';

class InventoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<InventoryBatch>> getInventoryBatchesForShop(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('inventory_batches')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InventoryBatch.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addInventoryBatch(InventoryBatch batch) {
    return _firestore
        .collection('shops')
        .doc(batch.shopId)
        .collection('inventory_batches')
        .add(batch.toMap());
  }

  Future<void> updateInventoryBatch(InventoryBatch batch) {
    return _firestore
        .collection('shops')
        .doc(batch.shopId)
        .collection('inventory_batches')
        .doc(batch.id)
        .update(batch.toMap());
  }

  Future<void> deleteInventoryBatch(String batchId, String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('inventory_batches')
        .doc(batchId)
        .delete();
  }

  Future<List<InventoryBatch>> searchInventoryBatches(
      String query, String shopId) async {
    final snapshot = await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('inventory_batches')
        .get();

    final batches =
        snapshot.docs.map((doc) => InventoryBatch.fromFirestore(doc)).toList();

    return batches
        .where((batch) =>
            batch.medicineName?.toLowerCase().contains(query.toLowerCase()) ??
            false ||
                batch.medicineId.toLowerCase().contains(query.toLowerCase()) ||
                batch.lotNumber.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
