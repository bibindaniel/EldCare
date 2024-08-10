import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/shop_medicine.dart';

class ShopMedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ShopMedicine>> getShopMedicinesStream(String shopId) {
    return _firestore
        .collection('inventory_batches')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) {
      print(
          'Snapshot received with ${snapshot.docs.length} documents'); // Debug print
      return snapshot.docs
          .map((doc) => ShopMedicine.fromSnapshot(doc))
          .toList();
    });
  }

  Future<List<ShopMedicine>> searchShopMedicines(
      String query, String shopId) async {
    final snapshot = await _firestore
        .collection('inventory_batches')
        .where('shopId', isEqualTo: shopId)
        .where('medicineName', isGreaterThanOrEqualTo: query)
        .where('medicineName', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    return snapshot.docs.map((doc) => ShopMedicine.fromSnapshot(doc)).toList();
  }
}
