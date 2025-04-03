import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/doctor/repositories/dashboard_repository.dart';

// Events
abstract class DashboardEvent {}

class LoadDashboardData extends DashboardEvent {
  final String doctorId;
  LoadDashboardData(this.doctorId);
}

// States
abstract class DashboardState {
  const DashboardState();
}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int patientCount;
  final int appointmentCount;
  final int prescriptionCount;
  final List<Map<String, dynamic>> latestPatients;
  final String doctorName;

  const DashboardLoaded({
    required this.patientCount,
    required this.appointmentCount,
    required this.prescriptionCount,
    required this.latestPatients,
    required this.doctorName,
  });
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _repository;

  DashboardBloc({required DashboardRepository repository})
      : _repository = repository,
        super(DashboardLoading()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final data = await _repository.getDashboardStats(event.doctorId);
      final doctorDoc = await _repository.firestore
          .collection('doctors')
          .doc(event.doctorId)
          .get();
      final doctorData = doctorDoc.data() ?? {};
      final doctorName = doctorData['displayName'] ??
          doctorData['name'] ??
          doctorData['fullName'] ??
          '';
      emit(DashboardLoaded(
        patientCount: data['patientCount'] as int,
        appointmentCount: data['appointmentCount'] as int,
        prescriptionCount: data['prescriptionCount'] as int,
        latestPatients: List<Map<String, dynamic>>.from(data['latestPatients']),
        doctorName: doctorName,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
