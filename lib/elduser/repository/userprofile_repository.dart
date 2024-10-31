import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_profile.dart';

class UserProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserProfile> getUserProfile(String userId) async {
    final docSnapshot = await _firestore.collection('users').doc(userId).get();
    if (docSnapshot.exists) {
      return UserProfile.fromMap(docSnapshot.data()!, docSnapshot.id);
    } else {
      throw Exception('User profile not found');
    }
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    await _firestore
        .collection('users')
        .doc(userProfile.id)
        .update(userProfile.toMap());
  }

  Future<String> uploadProfileImage(String userId, File image) async {
    final ref = _storage.ref().child('profile_images/$userId.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }
}
