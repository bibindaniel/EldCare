import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/admin/presentation/admin_panelscreen.dart';
import 'package:eldcare/auth/presentation/screens/login%20&%20singup/login_screen.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/delivery/presentation/homescreen/homescreen.dart';
import 'package:eldcare/elduser/presentation/homescreen/home_screen.dart';
import 'package:eldcare/pharmacy/presentation/homescreen/pharmhomescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/doctor/presentation/screens/auth/doctor_waiting_approval_screen.dart';
import 'package:eldcare/doctor/presentation/screens/home/doctor_home_screen.dart';
import 'package:eldcare/doctor/blocs/profile/doctor_profile_provider.dart';

class UserRedirection extends StatelessWidget {
  final String? userId; // Make userId optional
  final int? role; // Make role optional

  const UserRedirection({
    Key? key,
    this.userId,
    this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If userId or role is not provided, get from FirebaseAuth
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUserId = userId ?? authSnapshot.data?.uid;

        if (currentUserId == null) {
          return LoginScreen(); // Return to login if no user found
        }

        // If role is not provided, fetch from Firestore
        if (role == null) {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final userData =
                  userSnapshot.data?.data() as Map<String, dynamic>?;
              final userRole =
                  int.tryParse(userData?['role']?.toString() ?? '');

              if (userRole == null) {
                return LoginScreen(); // Return to login if no role found
              }

              return _handleUserRedirection(context, currentUserId, userRole);
            },
          );
        }

        return _handleUserRedirection(context, currentUserId, role!);
      },
    );
  }

  Widget _handleUserRedirection(BuildContext context, String userId, int role) {
    // If user is a doctor, check verification status
    if (role == 3) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final doctorData = snapshot.data?.data() as Map<String, dynamic>?;
          final isVerified = doctorData?['isVerified'] ?? false;

          if (!isVerified) {
            return const DoctorWaitingApprovalScreen();
          }

          return DoctorProfileProvider(
            child: DoctorHomeScreen(doctorId: userId),
          );
        },
      );
    }

    // For other roles, proceed normally
    return _buildHomeContent(context, role);
  }

  Widget _buildHomeContent(BuildContext context, int role) {
    switch (role) {
      case 1:
        return HomeScreen();
      case 2:
        return _CaretakerHome();
      case 3:
        return _DoctorHome();
      case 4:
        return const PharmacistHomeScreen();
      case 5:
        return const DeliveryPersonnelHomeScreen();
      case 6:
        return const AdminPanel();
      default:
        return const Center(child: Text('Unknown role'));
    }
  }
}

// class _ElderlyUserHome extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Welcome, Elderly User!', style: AppFonts.headline2),
//     );
//   }
// }

class _CaretakerHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Welcome, Caretaker!', style: AppFonts.headline2),
    );
  }
}

class _DoctorHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user ID from Firebase Auth
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Center(
        child: Text('No user found'),
      );
    }

    return DoctorHomeScreen(doctorId: currentUserId);
  }
}

// class _PharmacistHome extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Welcome, Pharmacist!', style: AppFonts.headline2),
//     );
//   }
// }

class _DeliveryPersonnelHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Welcome, Delivery Personnel!', style: AppFonts.headline2),
    );
  }
}
