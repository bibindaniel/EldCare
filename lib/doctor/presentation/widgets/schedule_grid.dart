import 'package:flutter/material.dart';
import '../../models/doctor_schedule.dart';
import '../../utils/schedule_utils.dart';

class ScheduleGrid extends StatelessWidget {
  final WeeklySchedule schedule;
  final Function(int dayOfWeek, DoctorSession session) onSessionTap;
  final Function(int dayOfWeek, bool isWorking) onDayToggle;
  final Function(int dayOfWeek, DoctorSession session) onAddSession;

  const ScheduleGrid({
    Key? key,
    required this.schedule,
    required this.onSessionTap,
    required this.onDayToggle,
    required this.onAddSession,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If width is less than 600, use compact layout
        if (constraints.maxWidth < 600) {
          return _buildCompactLayout(context);
        }
        // Otherwise use the regular grid layout
        return _buildRegularLayout(context);
      },
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Column(
      children: [
        _buildCompactHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: schedule.days.length,
            itemBuilder: (context, index) {
              return _buildCompactDayCard(schedule.days[index], context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: const Text(
        'Weekly Schedule',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCompactDayCard(DaySchedule day, BuildContext context) {
    final weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              weekDays[day.dayOfWeek - 1],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Switch(
              value: day.isWorkingDay,
              onChanged: (value) => onDayToggle(day.dayOfWeek, value),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        children: [
          if (day.isWorkingDay) ...[
            _buildCompactSessionList('Morning', day, context),
            _buildCompactSessionList('Afternoon', day, context),
            _buildCompactSessionList('Evening', day, context),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactSessionList(
      String timeLabel, DaySchedule day, BuildContext context) {
    final sessions = day.sessions.where((s) => s.label == timeLabel).toList()
      ..sort((a, b) {
        int aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        int bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timeLabel,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () =>
                    _showAddSessionDialog(context, day.dayOfWeek, timeLabel),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sessions
                .map((session) => _buildSessionChip(day.dayOfWeek, session))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularLayout(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Column(
                children: schedule.days
                    .map((day) => _buildDayRow(day, context))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[200],
      child: Row(
        children: [
          const SizedBox(width: 120, child: Text('Day')),
          ...['Morning', 'Afternoon', 'Evening'].map(
            (label) => SizedBox(
              width: 200,
              child: Text(label, textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(DaySchedule day, BuildContext context) {
    final weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 120,
              child: Row(
                children: [
                  Switch(
                    value: day.isWorkingDay,
                    onChanged: (value) => onDayToggle(day.dayOfWeek, value),
                  ),
                  Expanded(
                    child: Text(weekDays[day.dayOfWeek - 1]),
                  ),
                ],
              ),
            ),
            ...['Morning', 'Afternoon', 'Evening'].map(
              (timeLabel) => _buildTimeSlot(timeLabel, day, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(
      String timeLabel, DaySchedule day, BuildContext context) {
    final sessions = day.sessions.where((s) => s.label == timeLabel).toList()
      ..sort((a, b) {
        int aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        int bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });

    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (day.isWorkingDay)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () =>
                  _showAddSessionDialog(context, day.dayOfWeek, timeLabel),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sessions
                .map((session) => _buildSessionChip(day.dayOfWeek, session))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionChip(int dayOfWeek, DoctorSession session) {
    return InkWell(
      onTap: () => onSessionTap(dayOfWeek, session),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '${ScheduleUtils.formatTimeOfDay(session.startTime)} - '
          '${ScheduleUtils.formatTimeOfDay(session.endTime)}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
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
