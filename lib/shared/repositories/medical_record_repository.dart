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
    final doctorId = UserHelper.getCurrentUserId();
    print("Looking for records with doctor: $doctorId or demo-doctor-id");

    // Query for records with either the current doctor or demo doctor
    final snapshot = await _firestore
        .collection('medical_records')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .get();

    final records = snapshot.docs.map((doc) {
      final data = doc.data();
      final recordDoctorId = data['doctorId'] as String?;
      print("Found record with doctor ID: $recordDoctorId");

      return {
        'id': doc.id,
        ...data,
      };
    }).toList();

    print("Found ${records.length} total records for patient $patientId");
    return records;
  }

  Future<List<String>> getDoctorPatients() async {
    final doctorId = UserHelper.getCurrentUserId();
    print("Current doctor ID: $doctorId");

    // Query for the current doctor ID
    final snapshot = await _firestore
        .collection('medical_records')
        .where('doctorId', isEqualTo: doctorId)
        .get();

    // Also check for demo doctor records as a fallback
    final demoSnapshot = await _firestore
        .collection('medical_records')
        .where('doctorId', isEqualTo: 'demo-doctor-id')
        .get();

    final Set<String> patientIdSet = {};

    // Add IDs from both queries
    for (final doc in snapshot.docs) {
      final patientId = doc.data()['patientId'] as String?;
      if (patientId != null) patientIdSet.add(patientId);
    }

    for (final doc in demoSnapshot.docs) {
      final patientId = doc.data()['patientId'] as String?;
      if (patientId != null) patientIdSet.add(patientId);
    }

    final patientIds = patientIdSet.toList();
    print("Found ${patientIds.length} patients from medical records");
    return patientIds;
  }
}
