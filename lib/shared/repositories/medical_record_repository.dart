import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/shared/utils/user_helper.dart';

class MedicalRecordRepository {
  final FirebaseFirestore _firestore;

  MedicalRecordRepository([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createMedicalRecord({
    required String patientId,
    required String diagnosis,
    required List<String> medications,
    required String notes,
    String? appointmentId,
  }) async {
    final doctorId = UserHelper.getCurrentUserId();

    await _firestore.collection('medical_records').add({
      'patientId': patientId,
      'doctorId': doctorId,
      'diagnosis': diagnosis,
      'medications': medications,
      'notes': notes,
      'appointmentId': appointmentId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getPatientRecords(String patientId) async {
    final snapshot = await _firestore
        .collection('medical_records')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  Future<List<String>> getDoctorPatients() async {
    final doctorId = UserHelper.getCurrentUserId();
    final snapshot = await _firestore
        .collection('medical_records')
        .where('doctorId', isEqualTo: doctorId)
        .get();

    final patientIds = snapshot.docs
        .map((doc) => doc.data()['patientId'] as String)
        .toSet()
        .toList();

    return patientIds;
  }
}
