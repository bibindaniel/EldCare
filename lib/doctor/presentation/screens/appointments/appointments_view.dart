import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/doctor/blocs/appointment/doctor_appointment_bloc.dart';
import 'package:eldcare/doctor/blocs/appointment/doctor_appointment_event.dart';
import 'package:eldcare/doctor/blocs/appointment/doctor_appointment_state.dart';
import 'package:eldcare/shared/models/appointment.dart';
import 'package:eldcare/shared/repositories/appointment_repository.dart';
import 'package:eldcare/doctor/presentation/screens/appointments/consultation_screen.dart';
import 'package:intl/intl.dart';

class AppointmentsView extends StatefulWidget {
  final String doctorId;

  const AppointmentsView({required this.doctorId, super.key});

  @override
  State<AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<AppointmentsView> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.week;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorAppointmentBloc(
        appointmentRepository: AppointmentRepository(),
      )..add(LoadDoctorAppointments(
          doctorId: widget.doctorId,
          selectedDate: _selectedDay,
        )),
      child: Builder(builder: (context) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                title: Text('Appointments', style: AppFonts.headline2),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildCalendar(context),
                    _buildAppointmentStats(context),
                    _buildAppointmentsList(context),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('New Appointment'),
          ),
        );
      }),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return BlocBuilder<DoctorAppointmentBloc, DoctorAppointmentState>(
      builder: (context, state) {
        Map<DateTime, List<Appointment>> events = {};

        if (state is DoctorAppointmentLoaded) {
          events = state.appointmentsByDate;
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            calendarFormat: _calendarFormat,
            eventLoader: (day) {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              return events[normalizedDay] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              context.read<DoctorAppointmentBloc>().add(
                    LoadDoctorAppointments(
                      doctorId: widget.doctorId,
                      selectedDate: selectedDay,
                    ),
                  );
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentStats(BuildContext context) {
    return BlocBuilder<DoctorAppointmentBloc, DoctorAppointmentState>(
      builder: (context, state) {
        if (state is DoctorAppointmentLoaded) {
          final today = DateTime.now();
          final todayAppointments = state.appointments.where((a) {
            final appointmentDate = a.appointmentTime;
            return appointmentDate.year == today.year &&
                appointmentDate.month == today.month &&
                appointmentDate.day == today.day;
          }).toList();

          final pendingAppointments = todayAppointments
              .where((a) =>
                  a.status == AppointmentStatus.pending ||
                  a.status == AppointmentStatus.scheduled)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard('Today',
                      todayAppointments.length.toString(), 'Appointments'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Pending',
                      pendingAppointments.length.toString(), 'Requests'),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard('Today', '0', 'Appointments'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Pending', '0', 'Requests'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String count, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: AppFonts.bodyText2),
            Text(count,
                style: AppFonts.headline3.copyWith(color: kPrimaryColor)),
            Text(subtitle, style: AppFonts.bodyText2),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(BuildContext context) {
    return BlocBuilder<DoctorAppointmentBloc, DoctorAppointmentState>(
      builder: (context, state) {
        if (state is DoctorAppointmentLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DoctorAppointmentLoaded) {
          final appointments = state.appointments;

          if (appointments.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No appointments for this day',
                      style:
                          AppFonts.bodyText1.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          // Sort appointments by time
          appointments
              .sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return _buildAppointmentCard(context, appointment);
            },
          );
        } else if (state is DoctorAppointmentError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: AppFonts.bodyText1.copyWith(color: Colors.red),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    // Define status color and icon
    Color statusColor;
    IconData statusIcon;

    switch (appointment.status) {
      case AppointmentStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case AppointmentStatus.confirmed:
      case AppointmentStatus.scheduled:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case AppointmentStatus.completed:
        statusColor = Colors.blue;
        statusIcon = Icons.task_alt;
        break;
      case AppointmentStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case AppointmentStatus.inProgress:
        statusColor = Colors.purple;
        statusIcon = Icons.play_circle_filled;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: appointment.userPhotoUrl != null
              ? NetworkImage(appointment.userPhotoUrl!)
              : null,
          child: appointment.userPhotoUrl == null
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(appointment.userName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('h:mm a').format(appointment.appointmentTime)),
            Text('Reason: ${appointment.reason}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, color: statusColor),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: appointment.status == AppointmentStatus.confirmed ||
                      appointment.status == AppointmentStatus.scheduled
                  ? () {
                      // Start consultation
                      context.read<DoctorAppointmentBloc>().add(
                            StartConsultation(appointment.id),
                          );

                      // Navigate to consultation screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConsultationScreen(
                            appointment: appointment,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text('Start'),
            ),
          ],
        ),
        onTap: () {
          _showAppointmentDetails(context, appointment);
        },
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
    // Get the bloc before creating the bottom sheet
    final doctorAppointmentBloc = context.read<DoctorAppointmentBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appointment Details', style: AppFonts.headline3),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Patient'),
                subtitle: Text(appointment.userName),
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Time'),
                subtitle: Text(DateFormat('EEEE, MMMM d, yyyy • h:mm a')
                    .format(appointment.appointmentTime)),
              ),
              ListTile(
                leading: const Icon(Icons.medical_information),
                title: const Text('Reason'),
                subtitle: Text(appointment.reason),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Status'),
                subtitle: Text(_getStatusText(appointment.status)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (appointment.status == AppointmentStatus.pending)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        _confirmStatusChange(
                          context,
                          appointment,
                          AppointmentStatus.confirmed,
                          'Confirm this appointment?',
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  if (appointment.status != AppointmentStatus.cancelled &&
                      appointment.status != AppointmentStatus.completed)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        _confirmStatusChange(
                          context,
                          appointment,
                          AppointmentStatus.cancelled,
                          'Cancel this appointment?',
                        );
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  if (appointment.status == AppointmentStatus.confirmed ||
                      appointment.status == AppointmentStatus.scheduled)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        // Use the bloc instance we captured earlier
                        doctorAppointmentBloc.add(
                          StartConsultation(appointment.id),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConsultationScreen(
                              appointment: appointment,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.video_call),
                      label: const Text('Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      default:
        return 'Unknown';
    }
  }

  void _confirmStatusChange(
    BuildContext context,
    Appointment appointment,
    AppointmentStatus newStatus,
    String message,
  ) {
    // Get the bloc before creating the dialog
    final doctorAppointmentBloc = context.read<DoctorAppointmentBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(message),
        content: Text(
            'This will change the appointment status to ${_getStatusText(newStatus)}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Use the bloc instance we captured earlier
              doctorAppointmentBloc.add(
                UpdateAppointmentStatus(
                  doctorId: widget.doctorId,
                  appointmentId: appointment.id,
                  status: newStatus,
                ),
              );
            },
            child: const Text('Confirm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == AppointmentStatus.cancelled
                  ? Colors.red
                  : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
