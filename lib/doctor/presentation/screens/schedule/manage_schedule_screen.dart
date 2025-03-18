import 'package:eldcare/doctor/blocs/schedule/doctor_schedule_bloc.dart';
import 'package:eldcare/doctor/blocs/schedule/doctor_schedule_event.dart';
import 'package:eldcare/doctor/blocs/schedule/doctor_schedule_state.dart';
import 'package:eldcare/doctor/models/doctor_schedule.dart';
import 'package:eldcare/doctor/presentation/widgets/doctor_schedule_view.dart';
import 'package:eldcare/doctor/presentation/widgets/session_details_sheet.dart';
import 'package:eldcare/doctor/repositories/doctor_schedule_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageScheduleScreen extends StatefulWidget {
  final String doctorId;

  const ManageScheduleScreen({
    Key? key,
    required this.doctorId,
  }) : super(key: key);

  @override
  State<ManageScheduleScreen> createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorScheduleBloc(
        repository: context.read<DoctorScheduleRepository>(),
        doctorId: widget.doctorId,
      )..add(LoadWeeklySchedule(widget.doctorId)),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Manage Schedule'),
            actions: [
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _showCopyScheduleDialog(context),
              ),
            ],
          ),
          body: BlocConsumer<DoctorScheduleBloc, DoctorScheduleState>(
            listener: (context, state) {
              if (state is DoctorScheduleError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is DoctorScheduleLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DoctorScheduleLoaded) {
                return DoctorScheduleView(
                  schedule: state.schedule,
                  onSessionTap: (dayOfWeek, session) =>
                      _handleSessionTap(context, dayOfWeek, session),
                  onDayToggle: (dayOfWeek, isWorking) =>
                      _handleDayToggle(context, dayOfWeek, isWorking),
                  onAddSession: (dayOfWeek, session) {
                    context.read<DoctorScheduleBloc>().add(
                          AddDoctorSession(
                            dayOfWeek: dayOfWeek,
                            session: session,
                          ),
                        );
                  },
                );
              }
              return const Center(child: Text('No schedule data available'));
            },
          ),
        ),
      ),
    );
  }

  void _handleSessionTap(
      BuildContext context, int dayOfWeek, DoctorSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SessionDetailsSheet(
          dayOfWeek: dayOfWeek,
          session: session,
          onUpdate: (updatedSession) {
            context.read<DoctorScheduleBloc>().add(
                  UpdateDoctorSession(
                    dayOfWeek: dayOfWeek,
                    session: updatedSession,
                  ),
                );
          },
          onDelete: () {
            context.read<DoctorScheduleBloc>().add(
                  DeleteDoctorSession(
                    dayOfWeek: dayOfWeek,
                    sessionId: session.id,
                  ),
                );
          },
        ),
      ),
    );
  }

  void _handleDayToggle(BuildContext context, int dayOfWeek, bool isWorking) {
    context.read<DoctorScheduleBloc>().add(
          ToggleDayWorkingStatus(
            dayOfWeek: dayOfWeek,
            isWorkingDay: isWorking,
          ),
        );
  }

  Future<void> _showCopyScheduleDialog(BuildContext context) async {
    int? fromDay;
    int? toDay;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Copy Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'From Day'),
              items: _buildDayDropdownItems(),
              onChanged: (value) => fromDay = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'To Day'),
              items: _buildDayDropdownItems(),
              onChanged: (value) => toDay = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (fromDay != null && toDay != null) {
                context.read<DoctorScheduleBloc>().add(
                      CopyScheduleToDay(
                        fromDayOfWeek: fromDay!,
                        toDayOfWeek: toDay!,
                      ),
                    );
              }
              Navigator.pop(context);
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<int>> _buildDayDropdownItems() {
    final weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return List.generate(
      7,
      (index) => DropdownMenuItem(
        value: index + 1,
        child: Text(weekDays[index]),
      ),
    );
  }
}
