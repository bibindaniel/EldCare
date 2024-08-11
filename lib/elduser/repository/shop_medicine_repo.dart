import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/shop_medicine.dart';

class ShopMedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ShopMedicine> _fetchMedicineDetails(ShopMedicine medicine) async {
    final medicineDoc =
        await _firestore.collection('medicines').doc(medicine.medicineId).get();
    if (medicineDoc.exists) {
      final medicineData = medicineDoc.data();
      medicine.medicineName = medicineData?['name'];
      medicine.dosage = medicineData?['dosage'];
      final categoryId = medicineData?['categoryId'];
      if (categoryId != null) {
        final categoryDoc =
            await _firestore.collection('categories').doc(categoryId).get();
        final categoryData = categoryDoc.data();
        medicine.category = categoryData?['name'];
      }
    }
    return medicine;
  }

  Stream<List<ShopMedicine>> getShopMedicinesStream(String shopId) {
    return _firestore
        .collection('inventory_batches')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<ShopMedicine> medicines =
          snapshot.docs.map((doc) => ShopMedicine.fromSnapshot(doc)).toList();
      List<ShopMedicine> detailedMedicines = await Future.wait(
          medicines.map((medicine) => _fetchMedicineDetails(medicine)));
      return detailedMedicines;
    });
  }

  Future<List<ShopMedicine>> searchShopMedicines(
      String query, String shopId) async {
    final snapshot = await _firestore
        .collection('inventory_batches')
        .where('shopId', isEqualTo: shopId)
        .get();

    List<ShopMedicine> medicines =
        snapshot.docs.map((doc) => ShopMedicine.fromSnapshot(doc)).toList();
    List<ShopMedicine> detailedMedicines = await Future.wait(
        medicines.map((medicine) => _fetchMedicineDetails(medicine)));

    return detailedMedicines
        .where((medicine) =>
            medicine.medicineName
                ?.toLowerCase()
                .contains(query.toLowerCase()) ??
            false)
        .toList();
  }
}
