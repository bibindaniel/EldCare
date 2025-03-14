import 'package:eldcare/admin/presentation/adminstyles/adminstyles.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blueGrey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AdminStyles.primaryColor,
              ),
              child: Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildNavItem(context, Icons.dashboard, 'Dashboard', 0),
            _buildNavItem(context, Icons.people, 'Users Management', 1),
            _buildNavItem(
                context, Icons.medical_services, 'Shop Management', 2),
            _buildNavItem(context, Icons.local_shipping, 'Delivery Charges', 3),
            _buildNavItem(
                context, Icons.medical_services, 'Doctor Approval', 4),
            _buildNavItem(context, Icons.bar_chart, 'Reports & Analytics', 5),
            const Divider(color: Colors.white54),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white54),
      title: Text(title, style: const TextStyle(color: Colors.white54)),
      selected: selectedIndex == index,
      onTap: () => onItemSelected(index),
      selectedTileColor: Colors.blue,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.white54),
      title: const Text('Logout', style: TextStyle(color: Colors.white54)),
      onTap: () {
        Navigator.pop(context);
        context.read<AuthBloc>().add(LogoutEvent());
      },
    );
  }
}
