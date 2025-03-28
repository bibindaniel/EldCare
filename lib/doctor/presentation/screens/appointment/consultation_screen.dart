import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/shared/models/appointment.dart';
import 'package:eldcare/shared/repositories/appointment_repository.dart'
    as shared;
import 'package:eldcare/shared/blockchain/blockchain_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;
import 'package:eldcare/shared/repositories/medical_record_repository.dart';

class ConsultationScreen extends StatefulWidget {
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final String patientName;

  const ConsultationScreen({
    super.key,
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _patientData;
  List<Map<String, dynamic>> _previousRecords = [];

  @override
  void initState() {
    super.initState();
    _loadPatientData();
    _loadPreviousRecords();
  }

  Future<void> _loadPatientData() async {
    try {
      final patientDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.patientId)
          .get();

      if (patientDoc.exists) {
        setState(() {
          _patientData = patientDoc.data();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading patient data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPreviousRecords() async {
    try {
      final blockchainService = BlockchainService(FirebaseFirestore.instance);
      final records = await blockchainService.getDoctorPatientRecords(
        widget.doctorId,
        widget.patientId,
      );

      setState(() {
        _previousRecords = records
            .take(3)
            .map((record) => {
                  'diagnosis': record.diagnosis,
                  'medications': record.medications,
                  'date': record.createdAt.toString().substring(0, 10),
                })
            .toList();
      });
    } catch (e) {
      debugPrint('Error loading previous records: $e');
    }
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _medicationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultation: ${widget.patientName}'),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () async {
              try {
                final blockchainService =
                    BlockchainService(FirebaseFirestore.instance);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Testing blockchain write...')));

                await blockchainService.createConsultationRecord(
                  'test_${DateTime.now().millisecondsSinceEpoch}',
                  widget.doctorId,
                  widget.patientId,
                  'Test Diagnosis',
                  ['Test Medication'],
                  'Test Notes',
                );

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Test successful! Record added to blockchain'),
                  backgroundColor: Colors.green,
                ));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ));
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPatientInfoCard(),
                            const SizedBox(height: 16),
                            _buildPreviousRecordsSection(),
                            Text(
                              'New Consultation',
                              style: AppFonts.headline3,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _diagnosisController,
                              decoration: const InputDecoration(
                                labelText: 'Diagnosis',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a diagnosis';
                                }
                                return null;
                              },
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _medicationsController,
                              decoration: const InputDecoration(
                                labelText:
                                    'Medications & Prescriptions (one per line)',
                                border: OutlineInputBorder(),
                                hintText:
                                    'Paracetamol 500mg 1-0-1\nAmoxicillin 250mg 1-1-1',
                              ),
                              maxLines: 5,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter at least one medication';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Notes & Instructions',
                                border: OutlineInputBorder(),
                                hintText:
                                    'Patient instructions, follow-up details, etc.',
                              ),
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveConsultation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentColor,
                        ),
                        child: _isSaving
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Saving...',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              )
                            : const Text('COMPLETE CONSULTATION',
                                style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.security, color: Colors.blue),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This medical record will be securely stored on the blockchain',
                              style: AppFonts.body2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPatientInfoCard() {
    if (_patientData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('Loading patient information...')),
        ),
      );
    }

    final age = _patientData?['age'] ?? 'N/A';
    final gender = _patientData?['gender'] ?? 'N/A';
    final bloodGroup = _patientData?['bloodGroup'] ?? 'N/A';
    final phone = _patientData?['phone'] ?? 'N/A';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: kPrimaryColor),
                const SizedBox(width: 8),
                Text(widget.patientName, style: AppFonts.headline3),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Age: $age', style: AppFonts.body1),
                      const SizedBox(height: 4),
                      Text('Gender: $gender', style: AppFonts.body1),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Blood Group: $bloodGroup', style: AppFonts.body1),
                      const SizedBox(height: 4),
                      Text('Phone: $phone', style: AppFonts.body1),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousRecordsSection() {
    if (_previousRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Previous Records', style: AppFonts.headline3),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _previousRecords.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final record = _previousRecords[index];
              return ListTile(
                title: Text(record['diagnosis'], style: AppFonts.subtitle1),
                subtitle: Text(
                  '${record['medications'].join(", ")}\nDate: ${record['date']}',
                  style: AppFonts.body2,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  onPressed: () {
                    setState(() {
                      _diagnosisController.text = record['diagnosis'];
                      _medicationsController.text =
                          (record['medications'] as List<dynamic>).join('\n');
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Previous record data copied'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
                isThreeLine: true,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _saveConsultation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Save to Firestore appointments
      final appointmentRepository = shared.AppointmentRepository();

      final consultationDetails = {
        'diagnosis': _diagnosisController.text,
        'medications': _medicationsController.text.split('\n'),
        'notes': _notesController.text,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await appointmentRepository.updateAppointmentWithConsultation(
        widget.appointmentId,
        consultationDetails,
        AppointmentStatus.completed,
      );

      // 2. Save to blockchain (with error handling)
      try {
        final blockchainService = BlockchainService(FirebaseFirestore.instance);
        await blockchainService.createConsultationRecord(
          widget.appointmentId,
          widget.doctorId,
          widget.patientId,
          _diagnosisController.text,
          _medicationsController.text.split('\n'),
          _notesController.text,
        );
      } catch (blockchainError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Warning: Blockchain storage failed (using backup)'),
          backgroundColor: Colors.orange,
        ));
      }

      // 3. Also save to the direct Firebase record as backup
      final recordRepo = MedicalRecordRepository();
      await recordRepo.createMedicalRecord(
        patientId: widget.patientId,
        diagnosis: _diagnosisController.text,
        medications: _medicationsController.text.split('\n'),
        notes: _notesController.text,
        appointmentId: widget.appointmentId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Consultation saved successfully'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
}
