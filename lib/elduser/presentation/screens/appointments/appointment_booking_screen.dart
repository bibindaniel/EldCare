import 'package:eldcare/elduser/presentation/screens/appointments/book_appointment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/doctor/models/doctor.dart';
import 'package:eldcare/shared/models/appointment.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_bloc.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_event.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_state.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final Doctor doctor;

  const AppointmentBookingScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.doctor,
  }) : super(key: key);

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;
  DateTime? _selectedTime;
  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;

    // Load available slots for today
    _loadAvailableSlots();
  }

  void _loadAvailableSlots() {
    context.read<AppointmentBloc>().add(
          FetchDoctorAvailableSlots(
            doctorId: widget.doctor.userId,
            date: _selectedDay,
          ),
        );
  }

  void _bookAppointment() {
    if (_formKey.currentState!.validate() && _selectedTime != null) {
      // Calculate end time based on doctor's consultation duration
      final endTime = _selectedTime!.add(
        Duration(minutes: widget.doctor.consultationDuration ?? 30),
      );

      // Create appointment object
      final appointment = Appointment(
        id: '', // Will be set by Firestore
        userId: widget.userId,
        userName: widget.userName,
        userPhotoUrl: null, // Set this if available
        doctorId: widget.doctor.userId,
        doctorName: widget.doctor.fullName,
        doctorPhotoUrl: widget.doctor.profileImageUrl,
        appointmentTime: _selectedTime!,
        durationMinutes: widget.doctor.consultationDuration ?? 30,
        reason: _reasonController.text,
        status: AppointmentStatus.pending,
        createdAt: DateTime.now(),
        consultationFee: widget.doctor.consultationFee?.toDouble(),
      );

      // Navigate to payment screen with consultation fee
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookAppointmentScreen(
            appointmentToBook: _convertToSharedAppointment(appointment),
            consultationFee: widget.doctor.consultationFee?.toDouble(),
          ),
        ),
      );
    } else if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an appointment time'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fix the conversion method to include consultationFee
  Appointment _convertToSharedAppointment(Appointment appointment) {
    return Appointment(
      id: appointment.id,
      userId: appointment.userId,
      userName: appointment.userName,
      userPhotoUrl: appointment.userPhotoUrl,
      doctorId: appointment.doctorId,
      doctorName: appointment.doctorName,
      doctorPhotoUrl: appointment.doctorPhotoUrl,
      appointmentTime: appointment.appointmentTime,
      durationMinutes: appointment.durationMinutes,
      reason: appointment.reason,
      status: appointment.status,
      createdAt: appointment.createdAt,
      notes: appointment.notes,
      consultationFee: appointment.consultationFee,
      // Add these to ensure payment tracking
      isPaid: false,
      paymentId: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment', style: AppFonts.headline2),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor info card
                _buildDoctorCard(),

                const SizedBox(height: 24),

                // Calendar for date selection
                Text(
                  'Select Date',
                  style: AppFonts.headline3,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 60)),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _selectedTime = null; // Reset selected time
                        });
                        _loadAvailableSlots();
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: kLightPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonTextStyle: AppFonts.bodyText2,
                        titleTextStyle: AppFonts.headline4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Time slots
                Text(
                  'Select Time',
                  style: AppFonts.headline3,
                ),
                const SizedBox(height: 8),
                _buildTimeSlots(),

                const SizedBox(height: 24),

                // Reason for visit
                Text(
                  'Reason for Visit',
                  style: AppFonts.headline3,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    hintText: 'Brief description of your medical concern',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a reason for your visit';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Fee information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointment Details',
                          style: AppFonts.headline4,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Consultation Fee:',
                              style: AppFonts.bodyText1,
                            ),
                            Text(
                              '₹${widget.doctor.consultationFee ?? 0}',
                              style: AppFonts.bodyText1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Duration:',
                              style: AppFonts.bodyText1,
                            ),
                            Text(
                              '${widget.doctor.consultationDuration ?? 30} minutes',
                              style: AppFonts.bodyText1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Payment:',
                              style: AppFonts.bodyText1,
                            ),
                            Text(
                              'Pay at Clinic',
                              style: AppFonts.bodyText1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Book appointment button
                BlocConsumer<AppointmentBloc, AppointmentState>(
                  listener: (context, state) {
                    if (state is AppointmentActionSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    } else if (state is AppointmentActionFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: state is AppointmentActionInProgress
                            ? null
                            : _bookAppointment,
                        child: state is AppointmentActionInProgress
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                'Book Appointment',
                                style: AppFonts.bodyText1.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: kLightPrimaryColor,
              backgroundImage: widget.doctor.profileImageUrl != null
                  ? NetworkImage(widget.doctor.profileImageUrl!)
                  : null,
              child: widget.doctor.profileImageUrl == null
                  ? const Icon(Icons.person, size: 40, color: kPrimaryColor)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor.fullName,
                    style: AppFonts.headline3,
                  ),
                  Text(
                    widget.doctor.specialization,
                    style: AppFonts.bodyText1.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hospital: ${widget.doctor.hospitalName}',
                    style: AppFonts.bodyText2,
                  ),
                  const SizedBox(height: 4),
                  if (widget.doctor.emergencyAvailable == true)
                    Row(
                      children: [
                        const Icon(
                          Icons.emergency,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Emergency Services Available',
                          style: AppFonts.bodyText2.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        if (state is AvailableSlotsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is AvailableSlotsLoaded) {
          if (state.availableSlots.isEmpty) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No available slots for this day',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            );
          }

          return SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.availableSlots.length,
              itemBuilder: (context, index) {
                final slot = state.availableSlots[index];
                final isSelected = _selectedTime != null &&
                    _selectedTime!.isAtSameMomentAs(slot);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = slot;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: kPrimaryColor,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('h:mm a').format(slot),
                        style: AppFonts.bodyText1.copyWith(
                          color: isSelected ? Colors.white : kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else if (state is AvailableSlotsError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Error loading time slots: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadAvailableSlots,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Select a date to view available time slots',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
