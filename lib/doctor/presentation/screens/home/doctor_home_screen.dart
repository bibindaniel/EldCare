import 'package:flutter/material.dart';
import 'package:eldcare/doctor/presentation/screens/dashboard/doctor_dashboard_view.dart';
import 'package:eldcare/doctor/presentation/screens/appointments/appointments_view.dart';
import 'package:eldcare/doctor/presentation/screens/patients/patients_view.dart';
import 'package:eldcare/doctor/presentation/screens/profile/profile_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/doctor/blocs/profile/doctor_profile_bloc.dart';
import 'package:eldcare/doctor/blocs/profile/doctor_profile_event.dart';
import 'package:eldcare/doctor/repository/doctor_repository.dart';

class DoctorHomeScreen extends StatefulWidget {
  final String doctorId;
  const DoctorHomeScreen({super.key, required this.doctorId});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DoctorDashboardView(),
      const AppointmentsView(),
      const PatientsView(),
      ProfileView(doctorId: widget.doctorId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DoctorProfileBloc>(
          create: (context) {
            final bloc = DoctorProfileBloc(
              doctorRepository: DoctorRepository(),
            );
            // Load profile data immediately
            bloc.add(LoadDoctorProfile(widget.doctorId));
            return bloc;
          },
        ),
      ],
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            // Refresh profile data when switching to profile tab
            if (index == 3) {
              context
                  .read<DoctorProfileBloc>()
                  .add(LoadDoctorProfile(widget.doctorId));
            }
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Patients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
