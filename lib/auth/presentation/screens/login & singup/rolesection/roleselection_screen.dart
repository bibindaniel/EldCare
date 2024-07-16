import 'package:eldcare/auth/presentation/screens/login%20&%20singup/rolesection/elderlyuser.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';

class RoleSelectionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> roles = [
    {'name': 'Elderly User', 'icon': Icons.elderly},
    {'name': 'Caretaker', 'icon': Icons.health_and_safety},
    {'name': 'Doctor', 'icon': Icons.medical_services},
    {'name': 'Pharmacist', 'icon': Icons.local_pharmacy},
    {'name': 'Delivery Personnel', 'icon': Icons.delivery_dining},
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
                          _onRoleSelected(context, roles[index]['name']),
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

  void _onRoleSelected(BuildContext context, String role) {
    Widget screenWidget;
    switch (role) {
      case 'Elderly User':
        screenWidget = ElderlyUserDetailsScreen();
        break;
      case 'Caretaker':
        screenWidget = RoleDetailsScreen(
          role: role,
        );
        break;
      case 'Doctor':
        screenWidget = RoleDetailsScreen(
          role: role,
        );
        break;
      case 'Pharmacist':
        screenWidget = RoleDetailsScreen(
          role: role,
        );
        break;
      case 'Delivery Personnel':
        screenWidget = RoleDetailsScreen(
          role: role,
        );
        break;
      default:
        screenWidget = Scaffold(body: Center(child: Text('Unknown role')));
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screenWidget),
    );
  }
}

// Placeholder for the next screen
class RoleDetailsScreen extends StatelessWidget {
  final String role;

  const RoleDetailsScreen({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$role Details'),
      ),
      body: Center(
        child: Text('Enter $role specific details here'),
      ),
    );
  }
}
