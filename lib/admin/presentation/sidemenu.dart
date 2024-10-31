import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Admin Panel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          DrawerListTile(
            title: "Dashboard",
            icon: Icons.dashboard,
            press: () {},
          ),
          DrawerListTile(
            title: "Users Management",
            icon: Icons.people,
            press: () {},
          ),
          DrawerListTile(
            title: "Medicine Management",
            icon: Icons.medical_services,
            press: () {},
          ),
          DrawerListTile(
            title: "Schedules & Reminders",
            icon: Icons.schedule,
            press: () {},
          ),
          DrawerListTile(
            title: "Reports & Analytics",
            icon: Icons.bar_chart,
            press: () {},
          ),
          DrawerListTile(
            title: "Settings",
            icon: Icons.settings,
            press: () {},
          ),
          DrawerListTile(
            title: "Notifications",
            icon: Icons.notifications,
            press: () {},
          ),
          DrawerListTile(
            title: "Support & Feedback",
            icon: Icons.support,
            press: () {},
          ),
          const Divider(),
          DrawerListTile(
            title: "Logout",
            icon: Icons.logout,
            press: () {
              // Implement logout functionality here
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.press,
  });

  final String title;
  final IconData icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: Icon(icon),
      title: Text(title),
    );
  }
}
