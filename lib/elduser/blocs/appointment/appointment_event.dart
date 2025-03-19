import 'package:equatable/equatable.dart';
import 'package:eldcare/shared/models/appointment.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserAppointments extends AppointmentEvent {
  final String userId;

  const FetchUserAppointments(this.userId);

  @override
  List<Object> get props => [userId];
}

class FetchDoctorAppointments extends AppointmentEvent {
  final String doctorId;

  const FetchDoctorAppointments(this.doctorId);

  @override
  List<Object> get props => [doctorId];
}

class FetchDoctorAvailableSlots extends AppointmentEvent {
  final String doctorId;
  final DateTime date;

  const FetchDoctorAvailableSlots({
    required this.doctorId,
    required this.date,
  });

  @override
  List<Object> get props => [doctorId, date];
}

class BookAppointment extends AppointmentEvent {
  final Appointment appointment;

  const BookAppointment(this.appointment);

  @override
  List<Object> get props => [appointment];
}

class CancelAppointment extends AppointmentEvent {
  final String appointmentId;

  const CancelAppointment(this.appointmentId);

  @override
  List<Object> get props => [appointmentId];
}

class UpdateAppointmentStatus extends AppointmentEvent {
  final String appointmentId;
  final AppointmentStatus status;

  const UpdateAppointmentStatus({
    required this.appointmentId,
    required this.status,
  });

  @override
  List<Object> get props => [appointmentId, status];
}
