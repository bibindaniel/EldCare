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

  Future<String?> uploadProfileImage(String doctorId, File imageFile) async {
    try {
      // Create a reference to the location where we'll store the file
      final storageRef =
          _storage.ref().child('doctor_profiles').child('$doctorId.jpg');

      // Upload the file
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for the upload to complete
      final snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  Future<void> updateDoctorProfile(
    String doctorId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).update({
        ...updates,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update doctor profile: $e');
    }
  }

  Future<List<Doctor>> getAllApprovedDoctors() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('doctors')
          .where('isVerified', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Doctor.fromMap(
              {...doc.data() as Map<String, dynamic>, 'userId': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch approved doctors: $e');
    }
  }
}
