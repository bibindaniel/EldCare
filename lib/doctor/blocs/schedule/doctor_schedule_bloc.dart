import 'package:eldcare/doctor/blocs/schedule/doctor_schedule_event.dart';
import 'package:eldcare/doctor/blocs/schedule/doctor_schedule_state.dart';
import 'package:eldcare/doctor/repositories/doctor_schedule_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorScheduleBloc
    extends Bloc<DoctorScheduleEvent, DoctorScheduleState> {
  final DoctorScheduleRepository _repository;
  final String _doctorId;

  DoctorScheduleBloc({
    required DoctorScheduleRepository repository,
    required String doctorId,
  })  : _repository = repository,
        _doctorId = doctorId,
        super(DoctorScheduleInitial()) {
    on<LoadWeeklySchedule>(_onLoadWeeklySchedule);
    on<AddDoctorSession>(_onAddDoctorSession);
    on<UpdateDoctorSession>(_onUpdateDoctorSession);
    on<DeleteDoctorSession>(_onDeleteDoctorSession);
    on<ToggleDayWorkingStatus>(_onToggleDayWorkingStatus);
    on<CopyScheduleToDay>(_onCopyScheduleToDay);
  }

  Future<void> _onLoadWeeklySchedule(
    LoadWeeklySchedule event,
    Emitter<DoctorScheduleState> emit,
  ) async {
    emit(DoctorScheduleLoading());
    try {
      final schedule = await _repository.getWeeklySchedule(event.doctorId);
      emit(DoctorScheduleLoaded(schedule));
    } catch (e) {
      emit(DoctorScheduleError(e.toString()));
    }
  }

  Future<void> _onAddDoctorSession(
    AddDoctorSession event,
    Emitter<DoctorScheduleState> emit,
  ) async {
    final currentState = state;
    if (currentState is DoctorScheduleLoaded) {
      try {
        final updatedSchedule = await _repository.addSession(
          currentState.schedule.doctorId,
          event.dayOfWeek,
          event.session,
        );
        emit(DoctorScheduleLoaded(updatedSchedule));
      } catch (e) {
        emit(DoctorScheduleError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateDoctorSession(
    UpdateDoctorSession event,
    Emitter<DoctorScheduleState> emit,
  ) async {
    final currentState = state;
    if (currentState is DoctorScheduleLoaded) {
      try {
        final updatedSchedule = await _repository.updateSession(
          currentState.schedule.doctorId,
          event.dayOfWeek,
          event.session,
        );
        emit(DoctorScheduleLoaded(updatedSchedule));
      } catch (e) {
        emit(DoctorScheduleError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteDoctorSession(
    DeleteDoctorSession event,
    Emitter<DoctorScheduleState> emit,
  ) async {
    final currentState = state;
    if (currentState is DoctorScheduleLoaded) {
      try {
        final updatedSchedule = await _repository.deleteSession(
          currentState.schedule.doctorId,
          event.dayOfWeek,
          event.sessionId,
        );
        emit(DoctorScheduleLoaded(updatedSchedule));
      } catch (e) {
        emit(DoctorScheduleError(e.toString()));
      }
    }
  }

  Future<void> _onToggleDayWorkingStatus(
    ToggleDayWorkingStatus event,
    Emitter<DoctorScheduleState> emit,
  ) async {
    try {
      emit(DoctorScheduleLoading());

      final updatedSchedule = await _repository.updateDayWorkingStatus(
        _doctorId,
        event.dayOfWeek,
        event.isWorkingDay,
      );

      emit(DoctorScheduleLoaded(updatedSchedule));
    } catch (e) {
      emit(DoctorScheduleError(e.toString()));
    }
  }

  Future<void> _onCopyScheduleToDay(
    CopyScheduleToDay event,
    Emitter<DoctorScheduleState> emit,
  ) async {
    final currentState = state;
    if (currentState is DoctorScheduleLoaded) {
      try {
        final updatedSchedule = await _repository.copyScheduleToDay(
          currentState.schedule.doctorId,
          event.fromDayOfWeek,
          event.toDayOfWeek,
        );
        emit(DoctorScheduleLoaded(updatedSchedule));
      } catch (e) {
        emit(DoctorScheduleError(e.toString()));
      }
    }
  }
}
