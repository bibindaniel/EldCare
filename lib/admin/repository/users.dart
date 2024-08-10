import 'package:eldcare/elduser/models/user_profile.dart';
import 'package:eldcare/pharmacy/model/pharmacist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserProfile>> getElderlyUsers() async {
    final snapshot =
        await _firestore.collection('users').where('role', isEqualTo: 1).get();
    return snapshot.docs
        .map((doc) => UserProfile.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<PharmacistProfile>> getPharmacists() async {
    final snapshot =
        await _firestore.collection('users').where('role', isEqualTo: 4).get();
    return snapshot.docs
        .map((doc) => PharmacistProfile.fromMap(
              doc.data(),
            ))
        .toList();
  }

  Future<UserProfile> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserProfile.fromMap(doc.data()!, doc.id);
    } else {
      throw Exception('User not found');
    }
  }
}
