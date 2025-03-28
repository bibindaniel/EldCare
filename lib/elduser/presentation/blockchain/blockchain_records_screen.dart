// lib/elduser/presentation/screens/blockchain/blockchain_records_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/shared/blockchain/blockchain_service.dart';
import 'package:eldcare/shared/blockchain/medical_record_model.dart';

class BlockchainRecordsScreen extends StatefulWidget {
  final String userId;

  const BlockchainRecordsScreen({super.key, required this.userId});

  @override
  State<BlockchainRecordsScreen> createState() =>
      _BlockchainRecordsScreenState();
}

class _BlockchainRecordsScreenState extends State<BlockchainRecordsScreen> {
  late BlockchainService _blockchainService;
  bool _isLoading = true;
  List<MedicalRecord> _records = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _blockchainService = BlockchainService(FirebaseFirestore.instance);
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final records = await _blockchainService.getPatientRecords(widget.userId);

      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load blockchain records: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain Medical Records'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(_error!, style: TextStyle(color: Colors.red)))
              : _records.isEmpty
                  ? const Center(child: Text('No blockchain records found'))
                  : ListView.builder(
                      itemCount: _records.length,
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diagnosis: ${record.diagnosis}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    'Date: ${record.createdAt.toString().substring(0, 16)}'),
                                const SizedBox(height: 8),
                                Text('Doctor ID: ${record.doctorId}'),
                                const SizedBox(height: 8),
                                Text(
                                    'Medications: ${record.medications.join(", ")}'),
                                const SizedBox(height: 16),
                                Text(
                                  'Access Permissions:',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                ...record.accessGrantedTo
                                    .map((userId) => Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16, top: 4),
                                          child: Text('• $userId'),
                                        )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add UI to create a new blockchain record here
          _showAddRecordDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRecordDialog() {
    final diagnosisController = TextEditingController();
    final medicationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medical Record to Blockchain'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: diagnosisController,
              decoration: const InputDecoration(labelText: 'Diagnosis'),
            ),
            TextField(
              controller: medicationController,
              decoration: const InputDecoration(
                labelText: 'Medications (comma separated)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final diagnosis = diagnosisController.text.trim();
              final medications = medicationController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              if (diagnosis.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a diagnosis')),
                );
                return;
              }

              Navigator.pop(context);

              try {
                final record = MedicalRecord(
                  patientId: widget.userId,
                  doctorId: 'demo-doctor-id', // Replace with actual doctor ID
                  createdAt: DateTime.now(),
                  diagnosis: diagnosis,
                  medications: medications,
                  accessGrantedTo: [widget.userId, 'demo-doctor-id'],
                  consentLog: {
                    'demo-doctor-id': DateTime.now().toIso8601String()
                  },
                );

                await _blockchainService.createMedicalRecord(record);
                _loadRecords();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
