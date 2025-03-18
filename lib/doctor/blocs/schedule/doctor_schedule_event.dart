import 'package:eldcare/doctor/models/doctor_schedule.dart';

abstract class DoctorScheduleEvent {
  const DoctorScheduleEvent();
}

class LoadWeeklySchedule extends DoctorScheduleEvent {
  final String doctorId;

  LoadWeeklySchedule(this.doctorId);
}

class AddDoctorSession extends DoctorScheduleEvent {
  final int dayOfWeek;
  final DoctorSession session;

  AddDoctorSession({
    required this.dayOfWeek,
    required this.session,
  });
}

class UpdateDoctorSession extends DoctorScheduleEvent {
  final int dayOfWeek;
  final DoctorSession session;

  UpdateDoctorSession({
    required this.dayOfWeek,
    required this.session,
  });
}

class DeleteDoctorSession extends DoctorScheduleEvent {
  final int dayOfWeek;
  final String sessionId;

  DeleteDoctorSession({
    required this.dayOfWeek,
    required this.sessionId,
  });
}

class ToggleDayWorkingStatus extends DoctorScheduleEvent {
  final int dayOfWeek;
  final bool isWorkingDay;

  ToggleDayWorkingStatus({
    required this.dayOfWeek,
    required this.isWorkingDay,
  });
}

class CopyScheduleToDay extends DoctorScheduleEvent {
  final int fromDayOfWeek;
  final int toDayOfWeek;

  CopyScheduleToDay({
    required this.fromDayOfWeek,
    required this.toDayOfWeek,
  });
}
