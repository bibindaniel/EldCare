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
    on<InitiateAppointmentPayment>(_onInitiateAppointmentPayment);
    on<CompleteAppointmentPayment>(_onCompleteAppointmentPayment);
  }

  void _onFetchUserAppointments(
      FetchUserAppointments event, Emitter<AppointmentState> emit) async {
    emit(AppointmentsLoading());
    try {
      final appointments =
          await _appointmentRepository.getUserAppointments(event.userId);
      emit(UserAppointmentsLoaded(appointments));
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
      await _appointmentRepository.createAppointment(event.appointment);
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

      final currentState = state;
      if (currentState is UserAppointmentsLoaded) {
        final userId = currentState.appointments.isNotEmpty
            ? currentState.appointments.first.userId
            : null;
        if (userId != null) {
          add(FetchUserAppointments(userId));
        }
      }
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

  Future<void> _onInitiateAppointmentPayment(
      InitiateAppointmentPayment event, Emitter<AppointmentState> emit) async {
    emit(AppointmentActionInProgress());
    try {
      // Create a temporary appointment record with 'pending_payment' status
      final appointmentId = await _appointmentRepository
          .createPendingAppointment(event.appointment);

      // Get payment details (amount, currency, etc.)
      final paymentDetails = await _appointmentRepository
          .getAppointmentPaymentDetails(appointmentId);

      emit(AppointmentPaymentInitiated(
        paymentDetails: paymentDetails,
        pendingAppointmentId: appointmentId,
      ));
    } catch (e) {
      emit(AppointmentActionFailure('Failed to initiate payment: $e'));
    }
  }

  Future<void> _onCompleteAppointmentPayment(
      CompleteAppointmentPayment event, Emitter<AppointmentState> emit) async {
    emit(AppointmentActionInProgress());
    try {
      print(
          "Processing payment completion for appointment: ${event.appointmentId}");

      if (event.success) {
        // Update appointment with payment details and confirm status
        await _appointmentRepository.confirmAppointmentPayment(
          event.appointmentId,
          event.paymentId,
        );

        // Fetch updated appointments to refresh the UI
        final appointment = await _appointmentRepository
            .getAppointmentById(event.appointmentId);
        if (appointment != null) {
          add(FetchUserAppointments(appointment.userId));
        }

        emit(const AppointmentActionSuccess('Appointment booked successfully'));
      } else {
        // Cancel the pending appointment
        await _appointmentRepository.cancelAppointment(event.appointmentId);
        emit(const AppointmentActionFailure('Payment failed or cancelled'));
      }
    } catch (e) {
      print("ERROR in payment completion: $e");
      emit(AppointmentActionFailure('Payment processing error: $e'));
    }
  }
}
