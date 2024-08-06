import 'dart:io';

import 'package:eldcare/pharmacy/model/pharmacist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PharmacistProfileRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<PharmacistProfile?> getPharmacistProfile(String pharmacistId) async {
    try {
      print(
          'Fetching pharmacist profile for userId: $pharmacistId'); // Debugging
      final docSnapshot =
          await _firestore.collection('users').doc(pharmacistId).get();
      if (docSnapshot.exists) {
        print('Pharmacist profile data: ${docSnapshot.data()}'); // Debugging
        return PharmacistProfile.fromMap(
            {...docSnapshot.data()!, 'id': pharmacistId});
      } else {
        print(
            'Pharmacist profile not found for userId: $pharmacistId'); // Debugging
        return null;
      }
    } catch (e) {
      print('Error fetching pharmacist profile: $e'); // Debugging
      throw Exception('Failed to get pharmacist profile: $e');
    }
  }

  Future<void> updatePharmacistProfile(
      PharmacistProfile pharmacistProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(pharmacistProfile.id)
          .update(pharmacistProfile.toMap());
    } catch (e) {
      throw Exception('Failed to update pharmacist profile: $e');
    }
  }

  Future<String> uploadPharmacistProfileImage(File image) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final ref = _storage.ref().child('profile_images/$userId.jpg');
      await ref.putFile(image);
      final imageUrl = await ref.getDownloadURL();

      // Update the user profile with the new image URL
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': imageUrl,
      });

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  Future<void> verifyPharmacist(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'isVerified': true});
    } catch (e) {
      throw Exception('Failed to verify pharmacist: $e');
    }
  }

  Future<PharmacistProfile> getPharmacistProfileDetails(String userId) async {
    try {
      print(
          'Fetching pharmacist profile details for userId: $userId'); // Debugging
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        print('Pharmacist profile data: ${docSnapshot.data()}'); // Debugging
        return PharmacistProfile.fromMap(
            {...docSnapshot.data()!, 'id': userId});
      } else {
        throw Exception('Pharmacist profile not found');
      }
    } catch (e) {
      throw Exception('Failed to get pharmacist profile: $e');
    }
  }
}
