import 'dart:io';
import 'package:eldcare/elduser/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfileRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return UserProfile.fromMap(docSnapshot.data()!);
      } else {
        throw Exception('User profile not found');
      }
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(userProfile.id)
          .update(userProfile.toMap());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<String> uploadProfileImage(File image) async {
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

  Future<void> verifyUser(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'isVerified': true});
    } catch (e) {
      throw Exception('Failed to verify user: $e');
    }
  }
}
