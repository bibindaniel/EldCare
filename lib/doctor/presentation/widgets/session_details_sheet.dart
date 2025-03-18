import 'package:flutter/material.dart';
import '../../models/doctor_schedule.dart';
import '../../utils/schedule_utils.dart';

class SessionDetailsSheet extends StatefulWidget {
  final int dayOfWeek;
  final DoctorSession session;
  final Function(DoctorSession) onUpdate;
  final VoidCallback onDelete;

  const SessionDetailsSheet({
    Key? key,
    required this.dayOfWeek,
    required this.session,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<SessionDetailsSheet> createState() => _SessionDetailsSheetState();
}

class _SessionDetailsSheetState extends State<SessionDetailsSheet> {
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late int slotDuration;
  late int bufferTime;

  @override
  void initState() {
    super.initState();
    startTime = widget.session.startTime;
    endTime = widget.session.endTime;
    slotDuration = widget.session.slotDuration;
    bufferTime = widget.session.bufferTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Start Time'),
            trailing: Text(ScheduleUtils.formatTimeOfDay(startTime)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: startTime,
              );
              if (time != null) {
                setState(() => startTime = time);
              }
            },
          ),
          ListTile(
            title: const Text('End Time'),
            trailing: Text(ScheduleUtils.formatTimeOfDay(endTime)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: endTime,
              );
              if (time != null) {
                setState(() => endTime = time);
              }
            },
          ),
          ListTile(
            title: const Text('Slot Duration (minutes)'),
            trailing: DropdownButton<int>(
              value: slotDuration,
              items: [15, 30, 45, 60].map((duration) {
                return DropdownMenuItem(
                  value: duration,
                  child: Text('$duration min'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => slotDuration = value);
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Buffer Time (minutes)'),
            trailing: DropdownButton<int>(
              value: bufferTime,
              items: [0, 5, 10, 15].map((duration) {
                return DropdownMenuItem(
                  value: duration,
                  child: Text('$duration min'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => bufferTime = value);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: widget.onDelete,
                child: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedSession = widget.session.copyWith(
                    startTime: startTime,
                    endTime: endTime,
                    slotDuration: slotDuration,
                    bufferTime: bufferTime,
                  );
                  widget.onUpdate(updatedSession);
                  Navigator.pop(context);
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
