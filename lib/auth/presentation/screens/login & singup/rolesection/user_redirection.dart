import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/admin/presentation/admin_panelscreen.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/delivery/presentation/homescreen/homescreen.dart';
import 'package:eldcare/elduser/presentation/homescreen/home_screen.dart';
import 'package:eldcare/pharmacy/presentation/homescreen/pharmhomescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserRedirection extends StatelessWidget {
  const UserRedirection({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final userRoleString = userData['role'] as int;
          final userRole = userRoleString;
          print(userRole);
          return _buildHomeContent(context, userRole);
        },
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, int role) {
    switch (role) {
      case 1:
        return HomeScreen();
      case 2:
        print("care taker");
        return _CaretakerHome();
      case 3:
        return _DoctorHome();
      case 4:
        return const PharmacistHomeScreen();
      case 5:
        return DeliveryPersonnelHomeScreen();
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
    return const Center(
      child: Text('Welcome, Doctor!', style: AppFonts.headline2),
    );
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
