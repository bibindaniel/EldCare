import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/shared/models/appointment.dart';
import 'package:eldcare/shared/repositories/appointment_repository.dart';
import 'package:intl/intl.dart';

class ConsultationScreen extends StatefulWidget {
  final Appointment appointment;

  const ConsultationScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final TextEditingController _prescriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultation', style: AppFonts.headline3),
        backgroundColor: kPrimaryColor,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPatientInfoCard(),
                const SizedBox(height: 16),
                _buildTabsSection(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _completeConsultation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Complete Consultation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.appointment.userPhotoUrl != null
                      ? NetworkImage(widget.appointment.userPhotoUrl!)
                      : null,
                  child: widget.appointment.userPhotoUrl == null
                      ? const Icon(Icons.person)
                      : null,
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.appointment.userName,
                      style: AppFonts.headline4,
                    ),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy • h:mm a')
                          .format(widget.appointment.appointmentTime),
                      style: AppFonts.bodyText2,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Reason for Visit:',
              style: AppFonts.bodyText1.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.appointment.reason,
              style: AppFonts.bodyText1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsSection() {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Prescription'),
                Tab(text: 'Notes'),
              ],
              labelColor: kPrimaryColor,
              indicatorColor: kPrimaryColor,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPrescriptionTab(),
                  _buildNotesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Write Prescription',
            style: AppFonts.bodyText1.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _prescriptionController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Write prescription details here...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consultation Notes',
            style: AppFonts.bodyText1.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _notesController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Add notes about this consultation...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeConsultation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create consultation details map
      final Map<String, dynamic> consultationDetails = {
        'prescription': _prescriptionController.text,
        'notes': _notesController.text,
        'completedAt': DateTime.now(),
      };

      // Update the appointment with consultation details and mark as completed
      await AppointmentRepository().updateAppointmentWithConsultation(
        widget.appointment.id,
        consultationDetails,
        AppointmentStatus.completed,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
