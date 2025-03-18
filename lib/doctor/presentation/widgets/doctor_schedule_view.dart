import 'package:flutter/material.dart';
import '../../models/doctor_schedule.dart';
import '../../utils/schedule_utils.dart';

class DoctorScheduleView extends StatelessWidget {
  final WeeklySchedule schedule;
  final Function(int dayOfWeek, DoctorSession session) onSessionTap;
  final Function(int dayOfWeek, bool isWorking) onDayToggle;
  final Function(int dayOfWeek, DoctorSession session) onAddSession;

  const DoctorScheduleView({
    Key? key,
    required this.schedule,
    required this.onSessionTap,
    required this.onDayToggle,
    required this.onAddSession,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TabBarView(
                children: schedule.days
                    .map((day) => _buildDaySchedule(context, day))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        tabs: List.generate(
          7,
          (index) => Tab(
            height: 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weekDays[index],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    schedule.days[index].isWorkingDay
                        ? Icons.check_circle
                        : Icons.cancel,
                    key: ValueKey(schedule.days[index].isWorkingDay),
                    size: 14,
                    color: schedule.days[index].isWorkingDay
                        ? Colors.green
                        : Colors.red[300],
                  ),
                ),
              ],
            ),
          ),
        ),
        labelColor: Colors.blue[700],
        unselectedLabelColor: Colors.grey[600],
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySchedule(BuildContext context, DaySchedule day) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDayHeader(day),
          if (!day.isWorkingDay)
            _buildNonWorkingDayMessage()
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeSlotSection('Morning', day, context),
                _buildTimeSlotSection('Afternoon', day, context),
                _buildTimeSlotSection('Evening', day, context),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(DaySchedule day) {
    final weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          weekDays[day.dayOfWeek - 1],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Switch.adaptive(
          value: day.isWorkingDay,
          onChanged: (value) => onDayToggle(day.dayOfWeek, value),
          activeColor: Colors.blue[700],
        ),
      ],
    );
  }

  Widget _buildTimeSlotSection(
      String timeLabel, DaySchedule day, BuildContext context) {
    final sessions = day.sessions.where((s) => s.label == timeLabel).toList()
      ..sort((a, b) {
        int aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        int bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: () =>
                      _showAddSessionDialog(context, day.dayOfWeek, timeLabel),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  color: Colors.blue[700],
                ),
              ],
            ),
            if (sessions.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: sessions
                    .map((session) => _buildSessionChip(day.dayOfWeek, session))
                    .toList(),
              )
            else
              _buildEmptySessionMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionChip(int dayOfWeek, DoctorSession session) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSessionTap(dayOfWeek, session),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                '${ScheduleUtils.formatTimeOfDay(session.startTime)} - '
                '${ScheduleUtils.formatTimeOfDay(session.endTime)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySessionMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'No sessions scheduled',
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildNonWorkingDayMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Non-working day',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSessionDialog(
      BuildContext context, int dayOfWeek, String label) async {
    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (startTime != null) {
      TimeOfDay? endTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay(hour: startTime.hour + 1, minute: startTime.minute),
      );

      if (endTime != null) {
        final newSession = DoctorSession(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          label: label,
          startTime: startTime,
          endTime: endTime,
          slotDuration: 30,
          bufferTime: 5,
        );

        // Get existing sessions for this time period
        final existingSessions = schedule.days[dayOfWeek - 1].sessions
            .where((s) => s.label == label)
            .toList();

        if (ScheduleUtils.canAddSession(existingSessions, newSession)) {
          onAddSession(dayOfWeek, newSession);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Session overlaps with existing session')),
          );
        }
      }
    }
  }
}
