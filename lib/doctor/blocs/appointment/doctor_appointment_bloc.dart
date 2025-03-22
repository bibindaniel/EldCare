import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/shared/models/appointment.dart';
import 'package:eldcare/shared/repositories/appointment_repository.dart';
import 'package:eldcare/doctor/blocs/appointment/doctor_appointment_event.dart';
import 'package:eldcare/doctor/blocs/appointment/doctor_appointment_state.dart';

class DoctorAppointmentBloc
    extends Bloc<DoctorAppointmentEvent, DoctorAppointmentState> {
  final AppointmentRepository _appointmentRepository;

  DoctorAppointmentBloc({
    required AppointmentRepository appointmentRepository,
  })  : _appointmentRepository = appointmentRepository,
        super(DoctorAppointmentInitial()) {
    on<LoadDoctorAppointments>(_onLoadDoctorAppointments);
    on<LoadTodayAppointments>(_onLoadTodayAppointments);
    on<UpdateAppointmentStatus>(_onUpdateAppointmentStatus);
    on<StartConsultation>(_onStartConsultation);
  }

  Future<void> _onLoadDoctorAppointments(
    LoadDoctorAppointments event,
    Emitter<DoctorAppointmentState> emit,
  ) async {
    emit(DoctorAppointmentLoading());
    try {
      final appointments = await _appointmentRepository.getDoctorAppointments(
        event.doctorId,
        event.selectedDate,
      );

      // Group appointments by date for calendar events
      final Map<DateTime, List<Appointment>> appointmentsByDate = {};
      for (var appointment in appointments) {
        final date = DateTime(
          appointment.appointmentTime.year,
          appointment.appointmentTime.month,
          appointment.appointmentTime.day,
        );

        if (!appointmentsByDate.containsKey(date)) {
          appointmentsByDate[date] = [];
        }
        appointmentsByDate[date]!.add(appointment);
      }

      emit(DoctorAppointmentLoaded(
        appointments: appointments,
        appointmentsByDate: appointmentsByDate,
        selectedDate: event.selectedDate,
      ));
    } catch (e) {
      emit(DoctorAppointmentError(e.toString()));
    }
  }

  Future<void> _onLoadTodayAppointments(
    LoadTodayAppointments event,
    Emitter<DoctorAppointmentState> emit,
  ) async {
    emit(DoctorAppointmentLoading());
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final appointments =
          await _appointmentRepository.getDoctorAppointmentsByTimeRange(
        event.doctorId,
        startOfDay,
        endOfDay,
      );

      final pending = appointments
          .where((a) =>
              a.status == AppointmentStatus.pending ||
              a.status == AppointmentStatus.scheduled)
          .toList();

      emit(TodayAppointmentsLoaded(
        allAppointments: appointments,
        pendingAppointments: pending,
      ));
    } catch (e) {
      emit(DoctorAppointmentError(e.toString()));
    }
  }

  Future<void> _onUpdateAppointmentStatus(
    UpdateAppointmentStatus event,
    Emitter<DoctorAppointmentState> emit,
  ) async {
    try {
      // Store current state to restore after operation
      final currentState = state;
      emit(DoctorAppointmentActionInProgress());

      await _appointmentRepository.updateAppointmentStatus(
        event.appointmentId,
        event.status,
      );

      emit(DoctorAppointmentActionSuccess('Status updated successfully'));

      // Reload appointments to reflect changes
      if (currentState is DoctorAppointmentLoaded) {
        add(LoadDoctorAppointments(
          doctorId: event.doctorId,
          selectedDate: currentState.selectedDate,
        ));
      } else if (currentState is TodayAppointmentsLoaded) {
        add(LoadTodayAppointments(doctorId: event.doctorId));
      }
    } catch (e) {
      emit(DoctorAppointmentError(e.toString()));
    }
  }

  Future<void> _onStartConsultation(
    StartConsultation event,
    Emitter<DoctorAppointmentState> emit,
  ) async {
    try {
      emit(DoctorAppointmentActionInProgress());

      // Update appointment status to in-progress
      await _appointmentRepository.updateAppointmentStatus(
        event.appointmentId,
        AppointmentStatus.inProgress,
      );

      emit(ConsultationStarted(event.appointmentId));
    } catch (e) {
      emit(DoctorAppointmentError(e.toString()));
    }
  }
}
