import 'package:equatable/equatable.dart';
import 'package:eldcare/shared/models/appointment.dart';

abstract class DoctorAppointmentState extends Equatable {
  const DoctorAppointmentState();

  @override
  List<Object?> get props => [];
}

class DoctorAppointmentInitial extends DoctorAppointmentState {}

class DoctorAppointmentLoading extends DoctorAppointmentState {}

class DoctorAppointmentLoaded extends DoctorAppointmentState {
  final List<Appointment> appointments;
  final Map<DateTime, List<Appointment>> appointmentsByDate;
  final DateTime selectedDate;

  const DoctorAppointmentLoaded({
    required this.appointments,
    required this.appointmentsByDate,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [appointments, appointmentsByDate, selectedDate];
}

class TodayAppointmentsLoaded extends DoctorAppointmentState {
  final List<Appointment> allAppointments;
  final List<Appointment> pendingAppointments;

  const TodayAppointmentsLoaded({
    required this.allAppointments,
    required this.pendingAppointments,
  });

  @override
  List<Object?> get props => [allAppointments, pendingAppointments];
}

class DoctorAppointmentActionInProgress extends DoctorAppointmentState {}

class DoctorAppointmentActionSuccess extends DoctorAppointmentState {
  final String message;

  const DoctorAppointmentActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ConsultationStarted extends DoctorAppointmentState {
  final String appointmentId;

  const ConsultationStarted(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}

class DoctorAppointmentError extends DoctorAppointmentState {
  final String message;

  const DoctorAppointmentError(this.message);

  @override
  List<Object?> get props => [message];
}
