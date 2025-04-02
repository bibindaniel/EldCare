import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/shared/repositories/medical_record_repository.dart';
import 'patient_detail_screen.dart';

class DoctorPatientsScreen extends StatefulWidget {
  final String doctorId;

  const DoctorPatientsScreen({super.key, required this.doctorId});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<String> _patientIds = [];
  Map<String, Map<String, dynamic>> _patientDetails = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get patients from completed appointments
      final appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: widget.doctorId)
          .where('status', isEqualTo: 'completed')
          .get();

      // Extract unique patient IDs
      final Set<String> patientIdSet = {};
      for (final doc in appointmentsSnapshot.docs) {
        final patientId = doc.data()['patientId'] as String?;
        if (patientId != null) {
          patientIdSet.add(patientId);
        }
      }

      // Also check medical records as a backup
      final recordRepo = MedicalRecordRepository();
      final firestorePatientIds = await recordRepo.getDoctorPatients();
      patientIdSet.addAll(firestorePatientIds);

      _patientIds = patientIdSet.toList();

      // Debug information
      print(
          "Found ${_patientIds.length} patients for doctor ${widget.doctorId}");

      // Load patient details from Firebase
      _patientDetails.clear();
      for (final patientId in _patientIds) {
        try {
          final userDoc =
              await _firestore.collection('users').doc(patientId).get();

          if (userDoc.exists) {
            _patientDetails[patientId] = userDoc.data() ?? {};
            print("Patient $patientId data: ${userDoc.data()}");
          } else {
            print("Patient $patientId document doesn't exist");
          }
        } catch (e) {
          print('Error fetching details for patient $patientId: $e');
        }
      }

      // Inside _loadPatients
      // After getting patient IDs
      print("Doctor ID being used: ${widget.doctorId}");
      print("Patient IDs found: $_patientIds");

      // And also check appointments with demo doctor ID
      final demoAppointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: 'demo-doctor-id')
          .where('status', isEqualTo: 'completed')
          .get();

      for (final doc in demoAppointmentsSnapshot.docs) {
        final patientId = doc.data()['patientId'] as String?;
        if (patientId != null) {
          patientIdSet.add(patientId);
          print("Found patient $patientId from demo doctor appointment");
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      print('Error loading patients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Patients'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error', style: AppFonts.bodyText1),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPatients,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _patientIds.isEmpty
                  ? Center(
                      child: Text(
                        'No patients found. Complete consultations to see patients here.',
                        style: AppFonts.bodyText1,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _patientIds.length,
                      itemBuilder: (context, index) {
                        final patientId = _patientIds[index];
                        final patientDetails = _patientDetails[patientId] ?? {};
                        final patientName = patientDetails['displayName'] ??
                            patientDetails['name'] ??
                            'Unknown Patient';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: kAccentColor,
                              backgroundImage:
                                  patientDetails['profilePicture'] != null
                                      ? NetworkImage(
                                          patientDetails['profilePicture'])
                                      : null,
                              child: patientDetails['profilePicture'] == null
                                  ? Text(
                                      patientName.substring(0, 1).toUpperCase(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    )
                                  : null,
                            ),
                            title: Text(patientName, style: AppFonts.headline4),
                            subtitle: Text(
                              patientDetails['phone'] ?? 'No contact info',
                              style: AppFonts.bodyText2,
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PatientDetailScreen(
                                    doctorId: widget.doctorId,
                                    patientId: patientId,
                                    patientName: patientName,
                                  ),
                                ),
                              ).then((_) => _loadPatients());
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadPatients,
        backgroundColor: kAccentColor,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
