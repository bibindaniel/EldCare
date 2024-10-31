import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/shop_medicine.dart';
import 'package:eldcare/pharmacy/model/inventory_batch.dart';
import 'package:eldcare/pharmacy/model/medicine.dart';
import 'package:eldcare/pharmacy/model/category.dart';

class ShopMedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ShopMedicine>> getShopMedicinesStream(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('inventory_batches')
        .snapshots()
        .asyncMap((snapshot) async {
      List<InventoryBatch> batches = snapshot.docs
          .map((doc) => InventoryBatch.fromFirestore(doc))
          .toList();

      List<ShopMedicine> shopMedicines = [];

      for (var batch in batches) {
        DocumentSnapshot medicineDoc = await _firestore
            .collection('shops')
            .doc(shopId)
            .collection('medicines')
            .doc(batch.medicineId)
            .get();

        if (medicineDoc.exists) {
          Medicine medicine = Medicine.fromSnapshot(medicineDoc);
          DocumentSnapshot categoryDoc = await _firestore
              .collection('shops')
              .doc(shopId)
              .collection('categories')
              .doc(medicine.categoryId)
              .get();

          String categoryName = 'Uncategorized';
          if (categoryDoc.exists) {
            Category category = Category.fromSnapshot(categoryDoc);
            categoryName = category.name;
          }

          shopMedicines.add(ShopMedicine(
            id: batch.id,
            medicineId: batch.medicineId,
            medicineName: medicine.name,
            categoryId: medicine.categoryId,
            categoryName: categoryName,
            dosage: medicine.dosage,
            quantity: batch.quantity,
            price: batch.price,
            expiryDate: batch.expiryDate,
            supplier: batch.supplier,
            lotNumber: batch.lotNumber,
            shopId: batch.shopId,
            requiresPrescription: medicine.requiresPrescription,
          ));
        }
      }

      return shopMedicines;
    });
  }

  Future<List<ShopMedicine>> searchShopMedicines(
      String query, String shopId) async {
    final medicinesSnapshot = await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('medicines')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();

    List<ShopMedicine> shopMedicines = [];

    for (var medicineDoc in medicinesSnapshot.docs) {
      Medicine medicine = Medicine.fromSnapshot(medicineDoc);

      final batchSnapshot = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('inventory_batches')
          .where('medicineId', isEqualTo: medicine.id)
          .get();

      if (batchSnapshot.docs.isNotEmpty) {
        InventoryBatch batch =
            InventoryBatch.fromFirestore(batchSnapshot.docs.first);

        DocumentSnapshot categoryDoc = await _firestore
            .collection('shops')
            .doc(shopId)
            .collection('categories')
            .doc(medicine.categoryId)
            .get();

        String categoryName = 'Uncategorized';
        if (categoryDoc.exists) {
          Category category = Category.fromSnapshot(categoryDoc);
          categoryName = category.name;
        }

        shopMedicines.add(ShopMedicine(
          id: batch.id,
          medicineId: medicine.id,
          medicineName: medicine.name,
          categoryId: medicine.categoryId,
          categoryName: categoryName,
          dosage: medicine.dosage,
          quantity: batch.quantity,
          price: batch.price,
          expiryDate: batch.expiryDate,
          supplier: batch.supplier,
          lotNumber: batch.lotNumber,
          shopId: batch.shopId,
          requiresPrescription: medicine.requiresPrescription,
        ));
      }
    }

    return shopMedicines;
  }

  Stream<List<Category>> getCategoriesStream(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('categories')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Category.fromSnapshot(doc)).toList());
  }

  Future<GeoPoint> getShopLocation(String shopId) async {
    final shopDoc = await _firestore.collection('shops').doc(shopId).get();
    if (shopDoc.exists) {
      final data = shopDoc.data();
      if (data != null && data['location'] is GeoPoint) {
        return data['location'] as GeoPoint;
      }
    }
    throw Exception('Shop location not found');
  }
}
