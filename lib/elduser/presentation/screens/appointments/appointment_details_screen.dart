import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/shared/models/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailsScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('EEEE, MMMM d, yyyy').format(appointment.appointmentTime);
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details', style: AppFonts.headline2),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointment status card
            Card(
              color: statusColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: statusColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(appointment.status),
                      color: statusColor,
                      size: 36,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointment ${appointment.status.toString().split('.').last}',
                          style:
                              AppFonts.headline4.copyWith(color: statusColor),
                        ),
                        Text(
                          _getStatusMessage(appointment.status),
                          style:
                              AppFonts.bodyText2.copyWith(color: statusColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Doctor information
            Text('Doctor', style: AppFonts.headline3),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: kLightPrimaryColor,
                      backgroundImage: appointment.doctorPhotoUrl != null
                          ? NetworkImage(appointment.doctorPhotoUrl!)
                          : null,
                      child: appointment.doctorPhotoUrl == null
                          ? const Icon(Icons.person,
                              color: kPrimaryColor, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. ${appointment.doctorName}',
                            style: AppFonts.headline4,
                          ),
                          // Add more doctor details if available
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Appointment details
            Text('Appointment Details', style: AppFonts.headline3),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                        'Date', formattedDate, Icons.calendar_today),
                    const Divider(height: 24),
                    _buildDetailRow('Time', formattedTime, Icons.access_time),
                    const Divider(height: 24),
                    _buildDetailRow(
                        'Duration',
                        '${appointment.durationMinutes} minutes',
                        Icons.timelapse),
                    if (appointment.reason.isNotEmpty) ...[
                      const Divider(height: 24),
                      _buildDetailRow(
                          'Reason', appointment.reason, Icons.description),
                    ],
                    if (appointment.notes != null &&
                        appointment.notes!.isNotEmpty) ...[
                      const Divider(height: 24),
                      _buildDetailRow(
                          'Doctor\'s Notes', appointment.notes!, Icons.note),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            if (appointment.status == AppointmentStatus.pending ||
                appointment.status == AppointmentStatus.confirmed) ...[
              if (appointment.appointmentTime.isAfter(DateTime.now()))
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel Appointment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _showCancelConfirmation(context),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kPrimaryColor, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppFonts.bodyText2.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppFonts.bodyText1,
            ),
          ],
        ),
      ],
    );
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Icons.pending;
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.completed:
        return Icons.task_alt;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
      case AppointmentStatus.pendingPayment:
        return Icons.pending_actions;
      case AppointmentStatus.scheduled:
        return Icons.schedule;
    }
  }

  String _getStatusMessage(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Waiting for doctor confirmation';
      case AppointmentStatus.confirmed:
        return 'Your appointment is confirmed';
      case AppointmentStatus.completed:
        return 'This appointment has been completed';
      case AppointmentStatus.cancelled:
        return 'This appointment was cancelled';
      case AppointmentStatus.pendingPayment:
        return 'Waiting for payment confirmation';
      case AppointmentStatus.scheduled:
        return 'Appointment scheduled';
    }
  }

  void _showCancelConfirmation(BuildContext context) {
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
              // Cancel appointment logic here
              Navigator.pop(context);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
