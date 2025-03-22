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

class InitiateAppointmentPayment extends AppointmentEvent {
  final Appointment appointment;

  const InitiateAppointmentPayment(this.appointment);

  @override
  List<Object> get props => [appointment];
}

class CompleteAppointmentPayment extends AppointmentEvent {
  final String appointmentId;
  final String paymentId;
  final bool success;

  const CompleteAppointmentPayment({
    required this.appointmentId,
    required this.paymentId,
    required this.success,
  });

  @override
  List<Object> get props => [appointmentId, paymentId, success];
}

class RescheduleAppointment extends AppointmentEvent {
  final String appointmentId;
  final DateTime newTime;
  final int durationMinutes;

  const RescheduleAppointment({
    required this.appointmentId,
    required this.newTime,
    required this.durationMinutes,
  });

  @override
  List<Object> get props => [appointmentId, newTime, durationMinutes];
}
