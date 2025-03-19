import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_bloc.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_event.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_state.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_provider.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/elduser/presentation/screens/appointments/my_appointments_screen.dart';
import 'package:eldcare/elduser/presentation/screens/appointments/doctor_selection_screen.dart';
import 'package:eldcare/shared/repositories/appointment_repository.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppointmentProvider(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is Authenticated) {
            return AppointmentDashboard(
                userId: authState.user.uid,
                userName: authState.user.displayName ?? 'User');
          } else {
            return const Center(
              child: Text('Please sign in to access appointments'),
            );
          }
        },
      ),
    );
  }
}

class AppointmentDashboard extends StatefulWidget {
  final String userId;
  final String userName;

  const AppointmentDashboard({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<AppointmentDashboard> createState() => _AppointmentDashboardState();
}

class _AppointmentDashboardState extends State<AppointmentDashboard> {
  @override
  void initState() {
    super.initState();
    // Load data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentBloc>().add(FetchUserAppointments(widget.userId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: kPrimaryColor,
        child: Column(
          children: [
            // Header section with doctor illustration
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book Your Appointment',
                          style: AppFonts.headline2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Find a doctor and book your appointment',
                          style: AppFonts.bodyText1.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/doctor_appointment.png',
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.medical_services,
                        size: 80,
                        color: Colors.white,
                      );
                    },
                  ),
                ],
              ),
            ),

            // Book appointment button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: kPrimaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  // Create a new provider for the DoctorSelectionScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentProvider(
                        child: DoctorSelectionScreen(
                          userId: widget.userId,
                          userName: widget.userName,
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Book New Appointment',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),

            // Appointments section
            _buildAppointmentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text('My Appointments', style: AppFonts.headline2),
          const SizedBox(height: 20),

          // Add BlocBuilder to handle loading states
          BlocBuilder<AppointmentBloc, AppointmentState>(
            builder: (context, state) {
              if (state is AppointmentsLoading) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is AppointmentActionFailure) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Error: ${state.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<AppointmentBloc>()
                              .add(FetchUserAppointments(widget.userId));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      // Create a new provider for the MyAppointmentsScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentProvider(
                            child: MyAppointmentsScreen(userId: widget.userId),
                          ),
                        ),
                      );
                    },
                    child: const Text('View All Appointments',
                        style: TextStyle(fontSize: 16)),
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 300), // Extra space at bottom
        ],
      ),
    );
  }
}
