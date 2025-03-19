import 'dart:math';

import 'package:eldcare/doctor/blocs/profile/doctor_profile_event.dart';
import 'package:eldcare/doctor/blocs/schedule/doctor_schedule_event.dart';
import 'package:eldcare/doctor/blocs/schedule/doctor_schedule_state.dart';
import 'package:eldcare/doctor/models/doctor.dart';
import 'package:eldcare/doctor/models/doctor_schedule.dart';
import 'package:eldcare/doctor/presentation/screens/schedule/manage_schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/doctor/blocs/profile/doctor_profile_state.dart';
import 'package:eldcare/doctor/blocs/profile/doctor_profile_bloc.dart';
import 'package:eldcare/doctor/presentation/screens/profile/edit_profile_screen.dart';
import 'package:eldcare/doctor/blocs/schedule/doctor_schedule_bloc.dart';
import 'package:eldcare/doctor/repositories/doctor_schedule_repository.dart';
import 'package:eldcare/doctor/repositories/doctor_repository.dart';

class ProfileView extends StatelessWidget {
  final String doctorId;

  const ProfileView({
    super.key,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    // Get the bloc directly from the parent widget
    final doctorProfileBloc = BlocProvider.of<DoctorProfileBloc>(context);

    return BlocBuilder<DoctorProfileBloc, DoctorProfileState>(
      builder: (context, state) {
        if (state is DoctorProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is DoctorProfileError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${state.message}'),
            ),
          );
        }

        if (state is DoctorProfileLoaded) {
          final doctor = state.doctor;
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  expandedHeight: 160,
                  collapsedHeight: 140,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            kPrimaryColor,
                            kPrimaryColor.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.white,
                                  backgroundImage: doctor.profileImageUrl !=
                                          null
                                      ? NetworkImage(doctor.profileImageUrl!)
                                      : null,
                                  child: doctor.profileImageUrl == null
                                      ? const Icon(Icons.person,
                                          size: 25, color: kPrimaryColor)
                                      : null,
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Dr. ${doctor.fullName}',
                                    style: AppFonts.bodyText1.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    doctor.specialization,
                                    style: AppFonts.bodyText2
                                        .copyWith(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    centerTitle: true,
                    expandedTitleScale: 1.0,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        final doctorState = state;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              doctor: doctorState.doctor,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildProfileStats(),
                      const SizedBox(height: 16),
                      _buildAvailabilitySection(context),
                      const SizedBox(height: 16),
                      _buildConsultationSettings(
                          context, doctor, doctorProfileBloc),
                      const SizedBox(height: 16),
                      _buildProfessionalDetails(doctor),
                      const SizedBox(height: 16),
                      _buildAccountSettings(),
                    ]),
                  ),
                ),
              ],
            ),
          );
        }

        return const Scaffold(
          body: Center(
            child: Text('Something went wrong'),
          ),
        );
      },
    );
  }

  Widget _buildProfileStats() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Patients', '1.2k'),
          _buildDivider(),
          _buildStatItem('Experience', '8 yrs'),
          _buildDivider(),
          _buildStatItem('Rating', '4.8'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppFonts.headline3.copyWith(color: kPrimaryColor),
        ),
        Text(
          label,
          style: AppFonts.bodyText2,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildAvailabilitySection(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorScheduleBloc(
        repository: context.read<DoctorScheduleRepository>(),
        doctorId: doctorId,
      )..add(LoadWeeklySchedule(doctorId)),
      child: BlocBuilder<DoctorScheduleBloc, DoctorScheduleState>(
        builder: (context, state) {
          return Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Availability', style: AppFonts.headline4),
                      if (state is DoctorScheduleLoaded)
                        Switch(
                          value: state.schedule.isActive,
                          onChanged: (value) {
                            // TODO: Add ToggleAvailability event
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state is DoctorScheduleLoaded) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _buildTimeSlots(context, state.schedule),
                    ),
                  ] else if (state is DoctorScheduleLoading) ...[
                    const Center(child: CircularProgressIndicator()),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ManageScheduleScreen(doctorId: doctorId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_calendar),
                    label: const Text('Manage Schedule'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildTimeSlots(BuildContext context, WeeklySchedule schedule) {
    // Get current day of week (1 = Monday, 7 = Sunday)
    final now = DateTime.now();
    final currentDayOfWeek = now.weekday;

    // For debugging
    print("Current day of week: $currentDayOfWeek");

    // Find the current day's schedule
    final currentDay = schedule.days.firstWhere(
      (day) => day.dayOfWeek == currentDayOfWeek,
      orElse: () => DaySchedule(
          dayOfWeek: currentDayOfWeek, isWorkingDay: false, sessions: []),
    );

    // Print debugging info
    print(
        "Current day found: ${currentDay.dayOfWeek}, working: ${currentDay.isWorkingDay}");
    print("Sessions count: ${currentDay.sessions.length}");

    // If not a working day, show message
    if (!currentDay.isWorkingDay) {
      return [
        const Expanded(
          child: Text('Not working today'),
        ),
      ];
    }

    // If no sessions, show message
    if (currentDay.sessions.isEmpty) {
      return [
        const Expanded(
          child: Text('No session times set for today'),
        ),
      ];
    }

    // Simply display each session directly
    final List<Widget> slots = [];

    // Sort sessions by start time
    final sortedSessions = List<DoctorSession>.from(currentDay.sessions)
      ..sort((a, b) => a.startTime.hour.compareTo(b.startTime.hour));

    // Display up to 2 sessions
    for (var i = 0; i < min(sortedSessions.length, 2); i++) {
      final session = sortedSessions[i];
      final formattedStartTime = _formatTimeOfDay(session.startTime);
      final formattedEndTime = _formatTimeOfDay(session.endTime);

      // Determine period name based on time
      String periodName;
      if (session.startTime.hour < 12) {
        periodName = 'Morning';
      } else if (session.startTime.hour < 17) {
        periodName = 'Afternoon';
      } else {
        periodName = 'Evening';
      }

      slots.add(
        Flexible(
          child: _buildTimeSlot(
            periodName,
            '$formattedStartTime - $formattedEndTime',
            true,
          ),
        ),
      );
    }

    // If more than 2 sessions, add a "more" indicator
    if (sortedSessions.length > 2) {
      slots.add(
        Flexible(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ManageScheduleScreen(doctorId: doctorId),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: kPrimaryColor),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: const Column(
                children: [
                  Icon(Icons.more_horiz),
                  Text("More", style: AppFonts.bodyText2),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return slots;
  }

  // Helper to format TimeOfDay consistently
  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildTimeSlot(String title, String time, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: kPrimaryColor),
        borderRadius: BorderRadius.circular(8),
        color: isActive ? kPrimaryColor.withOpacity(0.1) : Colors.white,
      ),
      child: Column(
        children: [
          Text(title, style: AppFonts.bodyText2),
          Text(
            time,
            style: AppFonts.bodyText1.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationSettings(
      BuildContext context, Doctor doctor, DoctorProfileBloc bloc) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Consultation Settings', style: AppFonts.headline4),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Consultation Fee',
              '₹${doctor.consultationFee ?? 0}',
              Icons.attach_money,
              onTap: () => _updateConsultationFee(context, doctor, bloc),
            ),
            _buildSettingItem(
              'Duration',
              '${doctor.consultationDuration ?? 30} minutes',
              Icons.timer,
              onTap: () => _updateConsultationDuration(context, doctor, bloc),
            ),
            _buildSettingItem(
              'Emergency Available',
              doctor.emergencyAvailable ?? false ? 'Yes' : 'No',
              Icons.emergency,
              onTap: () => _toggleEmergencyAvailability(context, doctor, bloc),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String label, String value, IconData icon,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: kPrimaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: AppFonts.bodyText1),
            ),
            Text(
              value,
              style: AppFonts.bodyText1.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit, size: 20),
          ],
        ),
      ),
    );
  }

  void _updateConsultationFee(
      BuildContext context, Doctor doctor, DoctorProfileBloc bloc) {
    final feeController = TextEditingController(
      text: (doctor.consultationFee ?? 0).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Consultation Fee'),
        content: TextField(
          controller: feeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '₹',
            labelText: 'Fee Amount',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (feeController.text.isNotEmpty) {
                final fee = int.tryParse(feeController.text);
                if (fee != null) {
                  // Use the bloc passed as parameter
                  bloc.add(
                    UpdateDoctorProfile(
                      doctorId: doctor.userId,
                      updates: {'consultationFee': fee},
                    ),
                  );
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _updateConsultationDuration(
      BuildContext context, Doctor doctor, DoctorProfileBloc bloc) {
    final durations = [15, 30, 45, 60];
    final currentDuration = doctor.consultationDuration ?? 30;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Consultation Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: durations
              .map(
                (duration) => RadioListTile<int>(
                  title: Text('$duration minutes'),
                  value: duration,
                  groupValue: currentDuration,
                  onChanged: (value) {
                    if (value != null) {
                      // Use the bloc passed as parameter
                      bloc.add(
                        UpdateDoctorProfile(
                          doctorId: doctor.userId,
                          updates: {'consultationDuration': value},
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _toggleEmergencyAvailability(
      BuildContext context, Doctor doctor, DoctorProfileBloc bloc) {
    final current = doctor.emergencyAvailable ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${current ? 'Disable' : 'Enable'} Emergency Availability'),
        content: Text(
            'Are you sure you want to ${current ? 'disable' : 'enable'} emergency availability?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Use the bloc passed as parameter
              bloc.add(
                UpdateDoctorProfile(
                  doctorId: doctor.userId,
                  updates: {'emergencyAvailable': !current},
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalDetails(Doctor doctor) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.work, color: kPrimaryColor),
              const SizedBox(width: 8),
              Text(
                'Professional Details',
                style: AppFonts.headline3,
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          _buildDetailItem('Specialization', doctor.specialization),
          _buildDetailItem('Hospital Name', doctor.hospitalName),
          _buildDetailItem('Hospital Address', doctor.hospitalAddress),
          _buildDetailItem('Work Contact', doctor.workContact),
          _buildDetailItem('Work Email', doctor.workEmail),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildSettingTile(
            'Notifications',
            Icons.notifications_outlined,
            onTap: () {},
          ),
          _buildSettingTile(
            'Privacy & Security',
            Icons.security_outlined,
            onTap: () {},
          ),
          _buildSettingTile(
            'Help & Support',
            Icons.help_outline,
            onTap: () {},
          ),
          _buildSettingTile(
            'Terms & Conditions',
            Icons.description_outlined,
            onTap: () {},
          ),
          _buildSettingTile(
            'Logout',
            Icons.logout,
            isDestructive: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    IconData icon, {
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: AppFonts.bodyText1.copyWith(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
