import 'package:equatable/equatable.dart';
import 'package:eldcare/shared/models/appointment.dart';

abstract class DoctorAppointmentEvent extends Equatable {
  const DoctorAppointmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadDoctorAppointments extends DoctorAppointmentEvent {
  final String doctorId;
  final DateTime selectedDate;

  const LoadDoctorAppointments({
    required this.doctorId,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [doctorId, selectedDate];
}

class LoadTodayAppointments extends DoctorAppointmentEvent {
  final String doctorId;

  const LoadTodayAppointments({required this.doctorId});

  @override
  List<Object?> get props => [doctorId];
}

class UpdateAppointmentStatus extends DoctorAppointmentEvent {
  final String doctorId;
  final String appointmentId;
  final AppointmentStatus status;

  const UpdateAppointmentStatus({
    required this.doctorId,
    required this.appointmentId,
    required this.status,
  });

  @override
  List<Object?> get props => [doctorId, appointmentId, status];
}

class StartConsultation extends DoctorAppointmentEvent {
  final String appointmentId;

  const StartConsultation(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}
