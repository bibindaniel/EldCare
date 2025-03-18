import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/doctor/models/doctor.dart';

class DoctorRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DoctorRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<void> registerDoctor(
      Doctor doctor, Map<String, File> documentFiles) async {
    try {
      // Upload documents to Firebase Storage
      final Map<String, String> documentUrls = {};
      for (var entry in documentFiles.entries) {
        final ref = _storage.ref().child(
            'doctors/${doctor.userId}/documents/${entry.key}_${DateTime.now().millisecondsSinceEpoch}');
        await ref.putFile(entry.value);
        final url = await ref.getDownloadURL();
        documentUrls[entry.key] = url;
      }

      // Create doctor with document URLs
      final doctorWithDocs = Doctor(
        userId: doctor.userId,
        fullName: doctor.fullName,
        mobileNumber: doctor.mobileNumber,
        address: doctor.address,
        registrationNumber: doctor.registrationNumber,
        medicalCouncil: doctor.medicalCouncil,
        qualification: doctor.qualification,
        specialization: doctor.specialization,
        experience: doctor.experience,
        hospitalName: doctor.hospitalName,
        hospitalAddress: doctor.hospitalAddress,
        workContact: doctor.workContact,
        workEmail: doctor.workEmail,
        documents: documentUrls,
      );

      // Save doctor data to Firestore
      await _firestore
          .collection('doctors')
          .doc(doctor.userId)
          .set(doctorWithDocs.toMap());

      // Update user role in users collection
      await _firestore.collection('users').doc(doctor.userId).update({
        'role': '3', // doctor role
        'isVerified': false,
      });
    } catch (e) {
      throw Exception('Failed to register doctor: $e');
    }
  }

  Future<Doctor?> getDoctorById(String doctorId) async {
    try {
      final doc = await _firestore.collection('doctors').doc(doctorId).get();
      return doc.exists ? Doctor.fromMap(doc.data()!) : null;
    } catch (e) {
      throw Exception('Failed to get doctor: $e');
    }
  }

  Stream<Doctor?> getDoctorStream(String doctorId) {
    return _firestore
        .collection('doctors')
        .doc(doctorId)
        .snapshots()
        .map((doc) => doc.exists ? Doctor.fromMap(doc.data()!) : null);
  }

  Future<void> updateDoctorProfile(
    String doctorId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
