import 'package:flutter/material.dart';

class DoctorSession {
  final String id;
  final String label;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int slotDuration; // in minutes
  final int bufferTime; // in minutes
  final bool isActive;

  DoctorSession({
    required this.id,
    required this.label,
    required this.startTime,
    required this.endTime,
    this.slotDuration = 30,
    this.bufferTime = 5,
    this.isActive = true,
  });

  factory DoctorSession.fromJson(Map<String, dynamic> json) {
    final startTimeParts = (json['startTime'] as String).split(':');
    final endTimeParts = (json['endTime'] as String).split(':');

    return DoctorSession(
      id: json['id'],
      label: json['label'],
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      slotDuration: json['slotDuration'] ?? 30,
      bufferTime: json['bufferTime'] ?? 5,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'startTime': '${startTime.hour}:${startTime.minute}',
        'endTime': '${endTime.hour}:${endTime.minute}',
        'slotDuration': slotDuration,
        'bufferTime': bufferTime,
        'isActive': isActive,
      };

  DoctorSession copyWith({
    String? label,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? slotDuration,
    int? bufferTime,
    bool? isActive,
  }) {
    return DoctorSession(
      id: id,
      label: label ?? this.label,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      slotDuration: slotDuration ?? this.slotDuration,
      bufferTime: bufferTime ?? this.bufferTime,
      isActive: isActive ?? this.isActive,
    );
  }
}

class DaySchedule {
  final int dayOfWeek;
  final bool isWorkingDay;
  final List<DoctorSession> sessions;
  final String? customNote;

  DaySchedule({
    required this.dayOfWeek,
    this.isWorkingDay = true,
    required this.sessions,
    this.customNote,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    List<DoctorSession> parsedSessions = [];
    if (json['sessions'] != null) {
      parsedSessions = (json['sessions'] as List)
          .map((session) => DoctorSession.fromJson(session))
          .toList();
    }

    return DaySchedule(
      dayOfWeek: json['dayOfWeek'],
      isWorkingDay: json['isWorkingDay'] ?? true,
      sessions: parsedSessions,
      customNote: json['customNote'],
    );
  }

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'isWorkingDay': isWorkingDay,
        'sessions': sessions.map((session) => session.toJson()).toList(),
        'customNote': customNote,
      };

  DaySchedule copyWith({
    bool? isWorkingDay,
    List<DoctorSession>? sessions,
    String? customNote,
  }) {
    return DaySchedule(
      dayOfWeek: dayOfWeek,
      isWorkingDay: isWorkingDay ?? this.isWorkingDay,
      sessions: sessions ?? this.sessions,
      customNote: customNote ?? this.customNote,
    );
  }
}

class WeeklySchedule {
  final String doctorId;
  final List<DaySchedule> days;
  final bool isActive;

  WeeklySchedule({
    required this.doctorId,
    required this.days,
    this.isActive = true,
  });

  factory WeeklySchedule.empty(String doctorId) {
    return WeeklySchedule(
      doctorId: doctorId,
      days: List.generate(
        7,
        (index) => DaySchedule(
          dayOfWeek: index + 1,
          sessions: [],
        ),
      ),
    );
  }
}
