// lib/shared/blockchain/medical_record_model.dart
import 'dart:convert';

class MedicalRecord {
  final String patientId;
  final String doctorId;
  final DateTime createdAt;
  final String diagnosis;
  final List<String> medications;
  final List<String> accessGrantedTo;
  final Map<String, String> consentLog;
  final String? notes; // Optional consultation notes
  final String?
      appointmentId; // Link to appointment if created during consultation

  MedicalRecord({
    required this.patientId,
    required this.doctorId,
    required this.createdAt,
    required this.diagnosis,
    required this.medications,
    required this.accessGrantedTo,
    required this.consentLog,
    this.notes,
    this.appointmentId,
  });

  String toJson() {
    return jsonEncode({
      'patientId': patientId,
      'doctorId': doctorId,
      'createdAt': createdAt.toIso8601String(),
      'diagnosis': diagnosis,
      'medications': medications,
      'accessGrantedTo': accessGrantedTo,
      'consentLog': consentLog,
      'notes': notes,
      'appointmentId': appointmentId,
    });
  }

  factory MedicalRecord.fromJson(String jsonData) {
    final data = jsonDecode(jsonData);
    return MedicalRecord(
      patientId: data['patientId'],
      doctorId: data['doctorId'],
      createdAt: DateTime.parse(data['createdAt']),
      diagnosis: data['diagnosis'],
      medications: List<String>.from(data['medications']),
      accessGrantedTo: List<String>.from(data['accessGrantedTo']),
      consentLog: Map<String, String>.from(data['consentLog']),
      notes: data['notes'],
      appointmentId: data['appointmentId'],
    );
  }
}
