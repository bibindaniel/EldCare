import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/shared/blockchain/blockchain_service.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  final String doctorId;
  final String patientId;
  final String patientName;
  final VoidCallback onRecordAdded;

  const AddMedicalRecordScreen({
    super.key,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.onRecordAdded,
  });

  @override
  State<AddMedicalRecordScreen> createState() => _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _diagnosisController.dispose();
    _medicationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final blockchainService = BlockchainService(FirebaseFirestore.instance);

      final medications = _medicationsController.text
          .split('\n')
          .where((med) => med.trim().isNotEmpty)
          .toList();

      await blockchainService.createConsultationRecord(
        'manual_entry_${DateTime.now().millisecondsSinceEpoch}',
        widget.doctorId,
        widget.patientId,
        _diagnosisController.text,
        medications,
        _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medical record added successfully to blockchain'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onRecordAdded();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Record: ${widget.patientName}'),
        backgroundColor: kPrimaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Medical Record',
                        style: AppFonts.headline3,
                      ),
                      const SizedBox(height: 24),
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
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _medicationsController,
                        decoration: const InputDecoration(
                          labelText: 'Medications (one per line)',
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
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                          hintText: 'Additional notes or instructions',
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveRecord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccentColor,
                          ),
                          child: Text(
                            'SAVE TO BLOCKCHAIN',
                            style:
                                AppFonts.button.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.security,
                                    color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Blockchain Security',
                                  style: AppFonts.headline3
                                      .copyWith(color: Colors.blue),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This record will be securely stored on the blockchain and cannot be modified once saved. Both you and the patient will have permanent access.',
                              style: AppFonts.headline3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
