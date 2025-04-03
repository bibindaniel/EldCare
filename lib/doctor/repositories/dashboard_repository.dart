import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardRepository {
  final FirebaseFirestore firestore;

  DashboardRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getDashboardStats(String doctorId) async {
    try {
      // Get patient count
      final patientsQuery = await firestore
          .collection('medical_records')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      final uniquePatientIds = patientsQuery.docs
          .map((doc) => doc['patientId'] as String)
          .toSet()
          .length;

      // Get appointments data
      final appointmentsQuery = await firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', whereIn: ['confirmed', 'completed']).get();

      // Get latest patients with names (fixed with explicit typing)
      final QuerySnapshot<Map<String, dynamic>> latestPatientRecords =
          await firestore
              .collection('medical_records')
              .where('doctorId', isEqualTo: doctorId)
              .orderBy('createdAt', descending: true)
              .limit(5)
              .get();

      final List<Map<String, dynamic>> patientsWithDetails = [];

      for (final QueryDocumentSnapshot<Map<String, dynamic>> record
          in latestPatientRecords.docs) {
        final recordData = record.data();
        final patientId = recordData['patientId'] as String? ?? '';

        // Explicitly type the user document fetch
        final DocumentSnapshot<Map<String, dynamic>> userDoc =
            await firestore.collection('users').doc(patientId).get();

        patientsWithDetails.add({
          'record': recordData,
          'user': userDoc.data() ?? <String, dynamic>{},
        });
      }

      return {
        'patientCount': uniquePatientIds,
        'appointmentCount': appointmentsQuery.size,
        'prescriptionCount':
            patientsQuery.size, // Temporary - should have separate collection
        'latestPatients': patientsWithDetails,
      };
    } catch (e) {
      throw Exception('Error fetching dashboard data: ${e.toString()}');
    }
  }
}
