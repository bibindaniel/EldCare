import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/doctor/models/doctor.dart';
import 'package:eldcare/admin/repository/doctor_approval_repository.dart';

part 'doctor_approval_event.dart';
part 'doctor_approval_state.dart';

class DoctorApprovalBloc
    extends Bloc<DoctorApprovalEvent, DoctorApprovalState> {
  final DoctorApprovalRepository repository;
  bool _isLoading = false;

  DoctorApprovalBloc({required this.repository})
      : super(DoctorApprovalInitial()) {
    on<LoadPendingDoctors>(_onLoadPendingDoctors);
    on<ApproveDoctor>(_onApproveDoctor);
    on<RejectDoctor>(_onRejectDoctor);
  }

  Future<void> _onLoadPendingDoctors(
    LoadPendingDoctors event,
    Emitter<DoctorApprovalState> emit,
  ) async {
    if (_isLoading) return;

    _isLoading = true;
    emit(DoctorApprovalLoading());

    try {
      final doctors = await repository.getPendingDoctors();
      emit(DoctorApprovalLoaded(doctors));
    } catch (e) {
      emit(DoctorApprovalError(e.toString()));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _onApproveDoctor(
    ApproveDoctor event,
    Emitter<DoctorApprovalState> emit,
  ) async {
    try {
      await repository.approveDoctor(event.doctorId);
      await _sendEmail(
        to: event.doctor.workEmail,
        subject: 'Doctor Registration Approved',
        body: 'Your registration as a doctor has been approved.',
      );
      add(LoadPendingDoctors());
    } catch (e) {
      emit(DoctorApprovalError(e.toString()));
    }
  }

  Future<void> _onRejectDoctor(
    RejectDoctor event,
    Emitter<DoctorApprovalState> emit,
  ) async {
    try {
      await repository.rejectDoctor(event.doctorId);
      await _sendEmail(
        to: event.doctor.workEmail,
        subject: 'Doctor Registration Rejected',
        body: 'Your registration as a doctor has been rejected.',
      );
      add(LoadPendingDoctors());
    } catch (e) {
      emit(DoctorApprovalError(e.toString()));
    }
  }

  Future<void> _sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    // Implement email sending logic here
  }
}
