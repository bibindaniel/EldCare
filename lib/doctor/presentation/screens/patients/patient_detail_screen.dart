import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/shared/repositories/medical_record_repository.dart';
import 'package:eldcare/shared/blockchain/medical_record_model.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'add_medical_record_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final String doctorId;
  final String patientId;
  final String patientName;

  const PatientDetailScreen({
    super.key,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  bool _isLoading = true;
  List<MedicalRecord> _records = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch medical records directly from Firestore
      final recordRepo = MedicalRecordRepository();
      final recordsSnapshot =
          await recordRepo.getPatientRecords(widget.patientId);

      print("Doctor ID in detail screen: ${widget.doctorId}");
      print(
          "Fetched ${recordsSnapshot.length} records for patient ${widget.patientId}");

      // Convert to your MedicalRecord model
      final records = recordsSnapshot.map((record) {
        print("Record: ${record['medications']}");
        try {
          return MedicalRecord(
            patientId: record['patientId'] ?? '',
            doctorId: record['doctorId'] ?? '',
            createdAt:
                (record['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            diagnosis: record['diagnosis'] ?? '',
            medications: List<String>.from(record['medications'] ?? []),
            accessGrantedTo: [widget.patientId, widget.doctorId],
            consentLog: {widget.doctorId: DateTime.now().toIso8601String()},
            notes: record['notes'] ?? '',
            appointmentId: record['appointmentId'] ?? '',
          );
        } catch (e) {
          print("Error converting record: $e");
          return null;
        }
      }).toList();

      // Filter out null records, then sort by date (newest first)
      _records = records.where((r) => r != null).cast<MedicalRecord>().toList();
      _records.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load medical records: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Records: ${widget.patientName}'),
        backgroundColor: kPrimaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : _records.isEmpty
                  ? const Center(child: Text('No medical records found'))
                  : ListView.builder(
                      itemCount: _records.length,
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      record.createdAt
                                          .toString()
                                          .substring(0, 10),
                                      style: AppFonts.cardSubtitle,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: kPrimaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Blockchain Verified',
                                        style: TextStyle(
                                          color: kPrimaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Diagnosis: ${record.diagnosis}',
                                  style: AppFonts.headline4,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Medications:',
                                  style: AppFonts.cardSubtitle,
                                ),
                                const SizedBox(height: 4),
                                ...record.medications
                                    .map((med) => Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, bottom: 4),
                                          child: Text('• $med',
                                              style: AppFonts.bodyText2),
                                        ))
                                    .toList(),
                                if (record.notes != null &&
                                    record.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Notes:',
                                    style: AppFonts.cardSubtitle,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(record.notes!,
                                      style: AppFonts.bodyText2),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMedicalRecordScreen(
                doctorId: widget.doctorId,
                patientId: widget.patientId,
                patientName: widget.patientName,
                onRecordAdded: _loadRecords,
              ),
            ),
          );
        },
        backgroundColor: kAccentColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
    );
  }
}
