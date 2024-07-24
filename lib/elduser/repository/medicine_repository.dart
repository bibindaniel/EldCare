import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/medicine.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addMedicine(Medicine medicine) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('medicines')
            .add(medicine.toMap());
        print('Medicine added successfully');
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      print('Error adding medicine in repository: $e');
      throw Exception('Failed to add medicine: ${e.toString()}');
    }
  }

  Future<List<Medicine>> getMedicinesForDate(DateTime date) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      print('Fetching medicines for date: $date');

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .get();

      print('Fetched ${snapshot.docs.length} documents');

      final medicines = snapshot.docs.map((doc) {
        final data = doc.data();
        print('Document data: $data');
        return Medicine.fromMap(data, doc.id);
      }).toList();

      print('Parsed ${medicines.length} medicines');
      return medicines;
    } catch (e) {
      print('Error fetching medicines: $e');
      return [];
    }
  }
}
