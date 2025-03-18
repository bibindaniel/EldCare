import 'package:flutter/material.dart';
import '../models/doctor_schedule.dart';

class ScheduleUtils {
  static bool hasOverlap(
      List<DoctorSession> sessions, DoctorSession newSession) {
    for (var session in sessions) {
      if (_timeOverlaps(
        session.startTime,
        session.endTime,
        newSession.startTime,
        newSession.endTime,
      )) {
        return true;
      }
    }
    return false;
  }

  static bool _timeOverlaps(
    TimeOfDay start1,
    TimeOfDay end1,
    TimeOfDay start2,
    TimeOfDay end2,
  ) {
    final start1Minutes = start1.hour * 60 + start1.minute;
    final end1Minutes = end1.hour * 60 + end1.minute;
    final start2Minutes = start2.hour * 60 + start2.minute;
    final end2Minutes = end2.hour * 60 + end2.minute;

    return start1Minutes < end2Minutes && start2Minutes < end1Minutes;
  }

  static List<TimeOfDay> generateTimeSlots(DoctorSession session) {
    List<TimeOfDay> slots = [];
    int currentMinutes = session.startTime.hour * 60 + session.startTime.minute;
    final endMinutes = session.endTime.hour * 60 + session.endTime.minute;

    while (currentMinutes + session.slotDuration <= endMinutes) {
      slots.add(TimeOfDay(
        hour: currentMinutes ~/ 60,
        minute: currentMinutes % 60,
      ));
      currentMinutes += session.slotDuration + session.bufferTime;
    }

    return slots;
  }

  static String determineSessionLabel(TimeOfDay startTime) {
    if (startTime.hour < 12) {
      return 'Morning';
    } else if (startTime.hour < 17) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static bool canAddSession(
      List<DoctorSession> existingSessions, DoctorSession newSession) {
    // Check for minimum gap between sessions (e.g., 5 minutes)
    const minGapMinutes = 5;

    for (var session in existingSessions) {
      if (session.label == newSession.label) {
        // Only check sessions in same time period
        int newStartMinutes =
            newSession.startTime.hour * 60 + newSession.startTime.minute;
        int newEndMinutes =
            newSession.endTime.hour * 60 + newSession.endTime.minute;
        int existingStartMinutes =
            session.startTime.hour * 60 + session.startTime.minute;
        int existingEndMinutes =
            session.endTime.hour * 60 + session.endTime.minute;

        // Check if sessions overlap with minimum gap
        if ((newStartMinutes < existingEndMinutes + minGapMinutes) &&
            (existingStartMinutes < newEndMinutes + minGapMinutes)) {
          return false;
        }
      }
    }
    return true;
  }
}
