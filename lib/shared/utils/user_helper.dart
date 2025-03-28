import 'package:firebase_auth/firebase_auth.dart';

class UserHelper {
  static String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? 'unknown-user';
  }

  static bool isDoctor() {
    // If you have a user role field, use it here
    return true; // Temporary return for testing
  }
}
