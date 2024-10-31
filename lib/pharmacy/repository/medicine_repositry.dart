import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/pharmacy/model/medicine.dart';

class MedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Medicine>> getMedicinesStream(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('medicines')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Medicine.fromSnapshot(doc)).toList();
    });
  }

  Future<void> addMedicine(Medicine medicine) async {
    try {
      await _firestore
          .collection('shops')
          .doc(medicine.shopId)
          .collection('medicines')
          .add(medicine.toMap());
    } catch (e) {
      throw Exception('Failed to add medicine: $e');
    }
  }

  Future<void> updateMedicine(Medicine medicine) async {
    try {
      await _firestore
          .collection('shops')
          .doc(medicine.shopId)
          .collection('medicines')
          .doc(medicine.id)
          .update(medicine.toMap());
    } catch (e) {
      throw Exception('Failed to update medicine: $e');
    }
  }

  Future<void> deleteMedicine(String id, String shopId) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('medicines')
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete medicine: $e');
    }
  }

  Future<List<Medicine>> searchMedicines(String query, String shopId) async {
    try {
      final snapshot = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('medicines')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      return snapshot.docs.map((doc) => Medicine.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search medicines: $e');
    }
  }
}
