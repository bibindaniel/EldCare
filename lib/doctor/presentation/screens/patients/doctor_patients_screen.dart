import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/shared/blockchain/blockchain_service.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'patient_detail_screen.dart';

class DoctorPatientsScreen extends StatefulWidget {
  final String doctorId;

  const DoctorPatientsScreen({super.key, required this.doctorId});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  late BlockchainService _blockchainService;
  bool _isLoading = true;
  List<String> _patientIds = [];
  Map<String, Map<String, dynamic>> _patientDetails = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _blockchainService = BlockchainService(FirebaseFirestore.instance);
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final patientIds =
          await _blockchainService.getDoctorPatients(widget.doctorId);
      _patientIds = patientIds;

      // Load patient details from Firebase
      for (final patientId in patientIds) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(patientId)
              .get();

          if (userDoc.exists) {
            _patientDetails[patientId] = userDoc.data() ?? {};
          }
        } catch (e) {
          debugPrint('Error loading details for patient $patientId: $e');
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load patients: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        backgroundColor: kPrimaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : _patientIds.isEmpty
                  ? const Center(child: Text('No patients found'))
                  : ListView.builder(
                      itemCount: _patientIds.length,
                      itemBuilder: (context, index) {
                        final patientId = _patientIds[index];
                        final patientDetails = _patientDetails[patientId] ?? {};
                        final patientName =
                            patientDetails['displayName'] ?? 'Patient';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: kAccentColor,
                              child: Text(
                                patientName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
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
                              );
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
