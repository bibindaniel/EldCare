import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/medicine.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addMedicine(Medicine medicine) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .add(medicine.toMap());
    } else {
      throw Exception('User not logged in');
    }
  }

  Future<void> updateMedicineSchedule(Medicine medicine,
      List<DateTime> scheduleTimes, bool isBeforeFood) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .doc(medicine.id)
          .update({
        'scheduleTimes':
            scheduleTimes.map((time) => Timestamp.fromDate(time)).toList(),
        'isBeforeFood': isBeforeFood,
      });
    } else {
      throw Exception('User not logged in');
    }
  }
}
