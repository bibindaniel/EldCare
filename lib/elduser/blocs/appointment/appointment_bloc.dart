import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/shared/repositories/appointment_repository.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository _appointmentRepository;

  AppointmentBloc({required AppointmentRepository appointmentRepository})
      : _appointmentRepository = appointmentRepository,
        super(AppointmentInitial()) {
    on<FetchUserAppointments>(_onFetchUserAppointments);
    on<FetchDoctorAppointments>(_onFetchDoctorAppointments);
    on<FetchDoctorAvailableSlots>(_onFetchDoctorAvailableSlots);
    on<BookAppointment>(_onBookAppointment);
    on<CancelAppointment>(_onCancelAppointment);
    on<UpdateAppointmentStatus>(_onUpdateAppointmentStatus);
  }

  void _onFetchUserAppointments(
      FetchUserAppointments event, Emitter<AppointmentState> emit) async {
    emit(AppointmentsLoading());
    try {
      await emit.forEach(
        _appointmentRepository.getUserAppointments(event.userId),
        onData: (appointments) => UserAppointmentsLoaded(appointments),
        onError: (error, _) => AppointmentActionFailure(error.toString()),
      );
    } catch (e) {
      emit(AppointmentActionFailure('Failed to load appointments: $e'));
    }
  }

  void _onFetchDoctorAppointments(
      FetchDoctorAppointments event, Emitter<AppointmentState> emit) async {
    emit(AppointmentsLoading());
    try {
      await emit.forEach(
        _appointmentRepository.getDoctorAppointments(event.doctorId),
        onData: (appointments) => DoctorAppointmentsLoaded(appointments),
        onError: (error, _) => AppointmentActionFailure(error.toString()),
      );
    } catch (e) {
      emit(AppointmentActionFailure('Failed to load appointments: $e'));
    }
  }

  Future<void> _onFetchDoctorAvailableSlots(
      FetchDoctorAvailableSlots event, Emitter<AppointmentState> emit) async {
    emit(AvailableSlotsLoading());
    try {
      final slots = await _appointmentRepository.getAvailableSlots(
          event.doctorId, event.date);
      emit(AvailableSlotsLoaded(slots));
    } catch (e) {
      emit(AvailableSlotsError('Failed to load available slots: $e'));
    }
  }

  Future<void> _onBookAppointment(
      BookAppointment event, Emitter<AppointmentState> emit) async {
    emit(AppointmentActionInProgress());
    try {
      emit(const AppointmentActionSuccess('Appointment booked successfully'));
    } catch (e) {
      emit(AppointmentActionFailure('Failed to book appointment: $e'));
    }
  }

  Future<void> _onCancelAppointment(
      CancelAppointment event, Emitter<AppointmentState> emit) async {
    emit(AppointmentActionInProgress());
    try {
      await _appointmentRepository.cancelAppointment(event.appointmentId);
      emit(
          const AppointmentActionSuccess('Appointment cancelled successfully'));
    } catch (e) {
      emit(AppointmentActionFailure('Failed to cancel appointment: $e'));
    }
  }

  Future<void> _onUpdateAppointmentStatus(
      UpdateAppointmentStatus event, Emitter<AppointmentState> emit) async {
    emit(AppointmentActionInProgress());
    try {
      await _appointmentRepository.updateAppointmentStatus(
          event.appointmentId, event.status);
      emit(const AppointmentActionSuccess(
          'Appointment status updated successfully'));
    } catch (e) {
      emit(AppointmentActionFailure('Failed to update appointment status: $e'));
    }
  }
}
