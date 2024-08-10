import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/pharmacy/model/pharmacist.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PharmacistProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<PharmacistProfile> getPharmacistProfile(String pharmacistId) async {
    try {
      final docSnapshot =
          await _firestore.collection('pharmacists').doc(pharmacistId).get();
      if (docSnapshot.exists) {
        return PharmacistProfile.fromMap(docSnapshot.data()!);
      } else {
        return PharmacistProfile(id: pharmacistId);
      }
    } catch (e) {
      throw Exception('Error fetching pharmacist profile: ${e.toString()}');
    }
  }

  Future<void> updatePharmacistProfile(PharmacistProfile profile) async {
    try {
      await _firestore
          .collection('pharmacists')
          .doc(profile.id)
          .set(profile.toMap());
    } catch (e) {
      throw Exception('Error updating pharmacist profile: ${e.toString()}');
    }
  }

  Future<String> uploadProfileImage(String pharmacistId, File image) async {
    try {
      final ref =
          _storage.ref().child('pharmacist_profile_images/$pharmacistId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading profile image: ${e.toString()}');
    }
  }
}
