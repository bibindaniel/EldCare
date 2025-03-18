import 'package:equatable/equatable.dart';
import '../../models/doctor_schedule.dart';

abstract class DoctorScheduleState extends Equatable {
  const DoctorScheduleState();

  @override
  List<Object?> get props => [];
}

class DoctorScheduleInitial extends DoctorScheduleState {}

class DoctorScheduleLoading extends DoctorScheduleState {}

class DoctorScheduleLoaded extends DoctorScheduleState {
  final WeeklySchedule schedule;

  const DoctorScheduleLoaded(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class DoctorScheduleError extends DoctorScheduleState {
  final String message;

  const DoctorScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}
