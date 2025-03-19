import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/shared/models/appointment.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_bloc.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_event.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_state.dart';
import 'package:eldcare/elduser/presentation/screens/appointments/appointment_details_screen.dart';
import 'package:eldcare/shared/repositories/appointment_repository.dart';
import 'package:intl/intl.dart';

class MyAppointmentsScreen extends StatefulWidget {
  final String userId;

  const MyAppointmentsScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppointmentBloc(
        appointmentRepository: AppointmentRepository(),
      )..add(FetchUserAppointments(widget.userId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Appointments', style: AppFonts.headline2),
          backgroundColor: kPrimaryColor,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAppointmentsList(isUpcoming: true),
            _buildAppointmentsList(isUpcoming: false),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList({required bool isUpcoming}) {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        if (state is AppointmentsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UserAppointmentsLoaded) {
          final now = DateTime.now();

          final appointments = state.appointments.where((app) {
            if (isUpcoming) {
              return app.appointmentTime.isAfter(now) &&
                  (app.status == AppointmentStatus.pending ||
                      app.status == AppointmentStatus.confirmed ||
                      app.status == AppointmentStatus.scheduled);
            } else {
              return app.appointmentTime.isBefore(now) ||
                  app.status == AppointmentStatus.completed ||
                  app.status == AppointmentStatus.cancelled;
            }
          }).toList();

          if (appointments.isEmpty) {
            return Center(
              child: Text(
                isUpcoming
                    ? 'No upcoming appointments'
                    : 'No past appointments',
                style: AppFonts.headline3,
              ),
            );
          }

          return ListView.builder(
            itemCount: appointments.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return _buildAppointmentCard(appointment);
            },
          );
        } else if (state is AppointmentActionFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Error: ${state.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<AppointmentBloc>().add(
                        FetchUserAppointments(widget.userId),
                      ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('Select a tab to view appointments'));
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final formattedDate =
        DateFormat('EEEE, MMM d, yyyy').format(appointment.appointmentTime);
    final formattedTime =
        DateFormat('h:mm a').format(appointment.appointmentTime);

    // Determine status color
    Color statusColor;
    switch (appointment.status) {
      case AppointmentStatus.pending:
        statusColor = Colors.orange;
        break;
      case AppointmentStatus.confirmed:
        statusColor = Colors.green;
        break;
      case AppointmentStatus.completed:
        statusColor = Colors.blue;
        break;
      case AppointmentStatus.cancelled:
        statusColor = Colors.red;
        break;
      case AppointmentStatus.pendingPayment:
        statusColor = Colors.purple;
        break;
      case AppointmentStatus.scheduled:
        statusColor = Colors.teal;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentDetailsScreen(
                appointment: appointment,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: kLightPrimaryColor,
                    backgroundImage: appointment.doctorPhotoUrl != null
                        ? NetworkImage(appointment.doctorPhotoUrl!)
                        : null,
                    child: appointment.doctorPhotoUrl == null
                        ? const Icon(Icons.person, color: kPrimaryColor)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. ${appointment.doctorName}',
                          style: AppFonts.headline4,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: AppFonts.bodyText2,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      appointment.status.toString().split('.').last,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    formattedTime,
                    style: AppFonts.bodyText2,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.timelapse, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${appointment.durationMinutes} min',
                    style: AppFonts.bodyText2,
                  ),
                ],
              ),
              if (appointment.status != AppointmentStatus.cancelled &&
                  appointment.status != AppointmentStatus.completed &&
                  appointment.appointmentTime.isAfter(DateTime.now()))
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () => _confirmCancelAppointment(appointment),
                      child: const Text('Cancel Appointment'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmCancelAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content:
            const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              context.read<AppointmentBloc>().add(
                    CancelAppointment(appointment.id),
                  );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
