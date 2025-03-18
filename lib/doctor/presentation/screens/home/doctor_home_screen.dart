import 'package:flutter/material.dart';
import 'package:eldcare/doctor/presentation/screens/dashboard/doctor_dashboard_view.dart';
import 'package:eldcare/doctor/presentation/screens/appointments/appointments_view.dart';
import 'package:eldcare/doctor/presentation/screens/patients/patients_view.dart';
import 'package:eldcare/doctor/presentation/screens/profile/profile_view.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 0;

  // Define screens as a late initialized variable
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens in initState
    _screens = [
      const DoctorDashboardView(),
      const AppointmentsView(),
      const PatientsView(),
      const ProfileView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
