import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/doctor/models/doctor.dart';

class DoctorApprovalRepository {
  final FirebaseFirestore _firestore;
  static const int pageSize = 10;

  DoctorApprovalRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Doctor>> getPendingDoctors() async {
    try {
      final snapshot = await _firestore
          .collection('doctors')
          .where('isVerified', isEqualTo: false)
          .orderBy('registrationDate', descending: true)
          .limit(pageSize)
          .get();

      return snapshot.docs
          .map((doc) => Doctor.fromMap({...doc.data(), 'userId': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch pending doctors: $e');
    }
  }

  Future<void> approveDoctor(String doctorId) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).update({
        'isVerified': true,
        'verificationDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to approve doctor: $e');
    }
  }

  Future<void> rejectDoctor(String doctorId) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).update({
        'status': 'rejected',
        'rejectionDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reject doctor: $e');
    }
  }
}
