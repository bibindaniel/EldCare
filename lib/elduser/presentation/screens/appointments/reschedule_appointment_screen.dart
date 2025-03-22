import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/shared/models/appointment.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_bloc.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_event.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_state.dart';

class RescheduleAppointmentScreen extends StatefulWidget {
  final Appointment appointment;

  const RescheduleAppointmentScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<RescheduleAppointmentScreen> createState() =>
      _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState
    extends State<RescheduleAppointmentScreen> {
  late DateTime _selectedDate;
  DateTime? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Start with tomorrow as the default date
    _selectedDate = DateTime.now().add(const Duration(days: 1));

    // Load available slots for the selected date
    _loadAvailableSlots();
  }

  void _loadAvailableSlots() {
    context.read<AppointmentBloc>().add(
          FetchDoctorAvailableSlots(
            doctorId: widget.appointment.doctorId,
            date: _selectedDate,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentActionSuccess) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to MyAppointmentsScreen
          Navigator.pop(context);
        } else if (state is AppointmentActionFailure) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );

          // Reset loading state
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reschedule Appointment'),
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // Make the entire content scrollable
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Appointment details card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Appointment',
                                  style: AppFonts.kHeading2Style,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Date: ${DateFormat('MMM dd, yyyy').format(widget.appointment.appointmentDate)}',
                                  style: AppFonts.kBodyTextStyle,
                                ),
                                Text(
                                  'Time: ${DateFormat('hh:mm a').format(widget.appointment.appointmentDate)}',
                                  style: AppFonts.kBodyTextStyle,
                                ),
                                Text(
                                  'Duration: ${widget.appointment.durationMinutes} minutes',
                                  style: AppFonts.kBodyTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select New Date',
                          style: AppFonts.kHeading2Style,
                        ),
                        const SizedBox(height: 8),
                        // Calendar for date selection
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.35,
                            child: CalendarDatePicker(
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 60)),
                              onDateChanged: (date) {
                                setState(() {
                                  _selectedDate = date;
                                  _selectedTime = null;
                                });
                                _loadAvailableSlots();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select New Time',
                          style: AppFonts.kHeading2Style,
                        ),
                        const SizedBox(height: 8),
                        // Available time slots
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: BlocBuilder<AppointmentBloc, AppointmentState>(
                            builder: (context, state) {
                              if (state is AppointmentActionInProgress) {
                                return const Center(
                                    child: CircularProgressIndicator(
                                  color: kPrimaryColor,
                                ));
                              } else if (state is AvailableSlotsLoaded) {
                                if (state.availableSlots.isEmpty) {
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: Text(
                                          'No available slots for this date. Please select another date.',
                                          textAlign: TextAlign.center,
                                          style: AppFonts.kBodyTextStyle,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return _buildTimeSlots(state.availableSlots);
                              } else if (state is AppointmentActionFailure) {
                                return Center(
                                    child: Text(
                                  'Error: ${state.error}',
                                  style: AppFonts.kBodyTextStyle
                                      .copyWith(color: Colors.red),
                                ));
                              }
                              return const Center(
                                child: Text(
                                  'Select a date to see available slots',
                                  style: AppFonts.kBodyTextStyle,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Confirm button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _selectedTime != null
                                ? _confirmReschedule
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Confirm Reschedule',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlots(List<DateTime> slots) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: slots.map((slot) {
              final isSelected = _selectedTime != null &&
                  _selectedTime!.hour == slot.hour &&
                  _selectedTime!.minute == slot.minute;

              return ChoiceChip(
                label: Text(DateFormat('h:mm a').format(slot)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedTime = selected ? slot : null;
                  });
                },
                backgroundColor: Colors.grey[200],
                selectedColor: kPrimaryColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? kPrimaryColor : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _confirmReschedule() {
    if (_selectedTime == null) return;

    // Combine selected date and time
    final newDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    context.read<AppointmentBloc>().add(
          RescheduleAppointment(
            appointmentId: widget.appointment.id,
            newTime: newDateTime,
            durationMinutes: widget.appointment.durationMinutes,
          ),
        );
  }
}
