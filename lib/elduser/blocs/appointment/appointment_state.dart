import 'package:equatable/equatable.dart';
import 'package:eldcare/shared/models/appointment.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentsLoading extends AppointmentState {}

class UserAppointmentsLoaded extends AppointmentState {
  final List<Appointment> appointments;

  const UserAppointmentsLoaded(this.appointments);

  @override
  List<Object> get props => [appointments];
}

class DoctorAppointmentsLoaded extends AppointmentState {
  final List<Appointment> appointments;

  const DoctorAppointmentsLoaded(this.appointments);

  @override
  List<Object> get props => [appointments];
}

class AvailableSlotsLoading extends AppointmentState {}

class AvailableSlotsLoaded extends AppointmentState {
  final List<DateTime> availableSlots;

  const AvailableSlotsLoaded(this.availableSlots);

  @override
  List<Object> get props => [availableSlots];
}

class AvailableSlotsError extends AppointmentState {
  final String error;

  const AvailableSlotsError(this.error);

  @override
  List<Object> get props => [error];
}

class AppointmentActionInProgress extends AppointmentState {}

class AppointmentActionSuccess extends AppointmentState {
  final String message;

  const AppointmentActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AppointmentActionFailure extends AppointmentState {
  final String error;

  const AppointmentActionFailure(this.error);

  @override
  List<Object> get props => [error];
}
