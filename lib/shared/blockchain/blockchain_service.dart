// lib/shared/blockchain/blockchain_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'simulated_blockchain.dart';
import 'medical_record_model.dart';
import 'package:eldcare/shared/utils/user_helper.dart';

class BlockchainService {
  final FirebaseFirestore _firestore;
  late SimulatedBlockchain _blockchain;

  BlockchainService(this._firestore) {
    _blockchain = SimulatedBlockchain(_firestore);
  }

  Future<void> createMedicalRecord(MedicalRecord record) async {
    try {
      await _blockchain.addBlock(record.toJson());
      debugPrint('Medical record added to blockchain');
    } catch (e) {
      debugPrint('Error adding medical record to blockchain: $e');
      rethrow;
    }
  }

  Future<void> grantAccess(String recordHash, String doctorId) async {
    try {
      final chain = await _blockchain.getChain();
      final recordBlock = chain.firstWhere((block) => block.hash == recordHash);

      final record = MedicalRecord.fromJson(recordBlock.data);
      final updatedAccessList = [...record.accessGrantedTo, doctorId];
      final updatedConsentLog = {...record.consentLog};
      updatedConsentLog[doctorId] = DateTime.now().toIso8601String();

      final updatedRecord = MedicalRecord(
        patientId: record.patientId,
        doctorId: record.doctorId,
        createdAt: record.createdAt,
        diagnosis: record.diagnosis,
        medications: record.medications,
        accessGrantedTo: updatedAccessList,
        consentLog: updatedConsentLog,
      );

      await _blockchain.addBlock(updatedRecord.toJson());
      debugPrint('Access granted to doctor $doctorId');
    } catch (e) {
      debugPrint('Error granting access: $e');
      rethrow;
    }
  }

  Future<List<MedicalRecord>> getPatientRecords(String patientId) async {
    try {
      final chain = await _blockchain.getChain();
      final records = <MedicalRecord>[];

      for (final block in chain) {
        try {
          final record = MedicalRecord.fromJson(block.data);
          if (record.patientId == patientId) {
            records.add(record);
          }
        } catch (e) {
          // Skip blocks that don't contain valid medical records
        }
      }

      return records;
    } catch (e) {
      debugPrint('Error fetching patient records: $e');
      rethrow;
    }
  }

  Future<bool> verifyBlockchain() async {
    return await _blockchain.isChainValid();
  }

  // Get all patients a doctor has treated
  Future<List<String>> getDoctorPatients(String doctorId) async {
    try {
      final chain = await _blockchain.getChain();
      final patientIds = <String>{}; // Using a Set to avoid duplicates

      debugPrint('Blockchain chain length: ${chain.length}');

      for (final block in chain) {
        try {
          debugPrint('Block data: ${block.data}');
          final record = MedicalRecord.fromJson(block.data);
          debugPrint(
              'Record doctor ID: ${record.doctorId}, Current doctor: $doctorId');
          if (record.doctorId == doctorId) {
            patientIds.add(record.patientId);
            debugPrint('Added patient: ${record.patientId}');
          }
        } catch (e) {
          debugPrint('Error parsing block: $e');
        }
      }

      debugPrint('Total patients found: ${patientIds.length}');
      return patientIds.toList();
    } catch (e) {
      debugPrint('Error getting doctor patients: $e');
      rethrow;
    }
  }

  // Get patient records that a specific doctor created
  Future<List<MedicalRecord>> getDoctorPatientRecords(
      String doctorId, String patientId) async {
    try {
      final chain = await _blockchain.getChain();
      final records = <MedicalRecord>[];

      for (final block in chain) {
        try {
          final record = MedicalRecord.fromJson(block.data);
          if (record.patientId == patientId &&
              (record.doctorId == doctorId ||
                  record.accessGrantedTo.contains(doctorId))) {
            records.add(record);
          }
        } catch (e) {
          // Skip blocks that don't contain valid medical records
        }
      }

      // Sort records by date (newest first)
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return records;
    } catch (e) {
      debugPrint('Error fetching patient records: $e');
      rethrow;
    }
  }

  // Create a medical record during consultation
  Future<void> createConsultationRecord(
      String appointmentId,
      String doctorId,
      String patientId,
      String diagnosis,
      List<String> medications,
      String notes) async {
    try {
      // Use the current user ID as a fallback
      if (doctorId.isEmpty || doctorId == 'demo-doctor-id') {
        doctorId = UserHelper.getCurrentUserId();
      }

      final record = MedicalRecord(
        patientId: patientId,
        doctorId: doctorId, // This should now be consistent
        createdAt: DateTime.now(),
        diagnosis: diagnosis,
        medications: medications,
        accessGrantedTo: [patientId, doctorId],
        consentLog: {doctorId: DateTime.now().toIso8601String()},
        notes: notes,
        appointmentId: appointmentId,
      );

      // Add a visual indicator
      print('ADDING BLOCKCHAIN RECORD');
      await _blockchain.addBlock(record.toJson());
      return;
    } catch (e) {
      print('ERROR: $e');
      rethrow;
    }
  }
}
