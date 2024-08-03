import 'package:eldcare/auth/presentation/screens/login%20&%20singup/rolesection/user_redirection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_event.dart';

class RoleSelectionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> roles = [
    {'name': 'Elderly User', 'icon': Icons.elderly, 'role': 1},
    {'name': 'Caretaker', 'icon': Icons.health_and_safety, 'role': 2},
    {'name': 'Doctor', 'icon': Icons.medical_services, 'role': 3},
    {'name': 'Pharmacist', 'icon': Icons.local_pharmacy, 'role': 4},
    {'name': 'Delivery Personnel', 'icon': Icons.delivery_dining, 'role': 5},
  ];
  final String userId;

  RoleSelectionScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: kPrimaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to EldCare',
                    style: AppFonts.headline1.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Choose your role in the system',
                    style: AppFonts.bodyText1.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                itemCount: roles.length,
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          roles[index]['icon'],
                          color: kPrimaryColor,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        roles[index]['name'],
                        style: AppFonts.bodyText1.copyWith(color: kTextColor),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: kPrimaryColor,
                        size: 18,
                      ),
                      onTap: () =>
                          _onRoleSelected(context, roles[index]['role']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRoleSelected(BuildContext context, int role) {
    // Add the SetUserRole event to the AuthBloc
    BlocProvider.of<AuthBloc>(context).add(SetUserRole(userId, role));
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const UserRedirection()),
      (Route<dynamic> route) => false,
    );
  }
}
