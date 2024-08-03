import 'package:eldcare/elduser/models/medicine.dart';
import 'package:eldcare/elduser/presentation/homescreen/notification_service.dart';
import 'package:eldcare/elduser/repository/medicine_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workmanager/workmanager.dart';

part 'medicine_event.dart';
part 'medicine_state.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final MedicineRepository _repository = MedicineRepository();
  final NotificationService _notificationService = NotificationService();

  MedicineBloc() : super(MedicineInitial()) {
    on<AddAndScheduleMedicine>(_onAddAndScheduleMedicine);
    on<FetchMedicinesForDate>(_onFetchMedicinesForDate);
    on<UpdateMedicine>(_onUpdateMedicine);
    on<RemoveMedicine>(_onRemoveMedicine);
    on<FetchUpcomingMedicines>(_onFetchUpcomingMedicines);
    on<FetchCompletedMedicines>(_onFetchCompletedMedicines);
  }

  void _onAddAndScheduleMedicine(
      AddAndScheduleMedicine event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      await _repository.addMedicine(event.medicine);
      await _scheduleNotifications(event.medicine);
      emit(MedicineSuccess());
    } catch (e) {
      print('Error adding medicine: $e');
      emit(MedicineError('Failed to add medicine: ${e.toString()}'));
    }
  }

  void _onFetchMedicinesForDate(
      FetchMedicinesForDate event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      // Create a date range for the entire day
      final startOfDay =
          DateTime(event.date.year, event.date.month, event.date.day);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(microseconds: 1));

      final medicines =
          await _repository.getMedicinesForDateRange(startOfDay, endOfDay);
      emit(MedicinesLoaded(medicines));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  void _onFetchUpcomingMedicines(
      FetchUpcomingMedicines event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      final upcomingMedicines = await _repository.getUpcomingMedicines();
      emit(UpcomingMedicinesLoaded(upcomingMedicines));
    } catch (e) {
      print('Error fetching upcoming medicines: $e');
      emit(
          MedicineError('Failed to fetch upcoming medicines: ${e.toString()}'));
    }
  }

  void _onUpdateMedicine(
      UpdateMedicine event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      await _repository.updateMedicine(event.medicine);
      await _scheduleNotifications(event.medicine);
      emit(MedicineSuccess());
    } catch (e) {
      print('Error updating medicine: $e');
      emit(MedicineError('Failed to update medicine: ${e.toString()}'));
    }
  }

  void _onRemoveMedicine(
      RemoveMedicine event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      await _repository.removeMedicine(event.medicineId);
      emit(MedicineSuccess());
    } catch (e) {
      print('Error removing medicine: $e');
      emit(MedicineError('Failed to remove medicine: ${e.toString()}'));
    }
  }

  void _onFetchCompletedMedicines(
      FetchCompletedMedicines event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      final completedMedicines = await _repository.getCompletedMedicines();
      emit(CompletedMedicinesLoaded(completedMedicines));
    } catch (e) {
      print('Error fetching completed medicines: $e');
      emit(MedicineError(
          'Failed to fetch completed medicines: ${e.toString()}'));
    }
  }

  Future<void> _scheduleNotifications(Medicine medicine) async {
    for (var scheduleTime in medicine.scheduleTimes) {
      int notificationId = medicine.id.hashCode + scheduleTime.hashCode;
      String notificationTitle = 'Time to take ${medicine.name}';
      String notificationBody = 'Dosage: ${medicine.dosage}';

      DateTime now = DateTime.now();
      DateTime scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        scheduleTime.hour,
        scheduleTime.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(Duration(days: 1));
      }

      await _notificationService.showNotification(
        notificationId,
        notificationTitle,
        notificationBody,
        scheduledDate,
      );

      // Schedule a background task for recurring notifications
      await Workmanager().registerPeriodicTask(
        'medicine_notification_$notificationId',
        'scheduleMedicineNotification',
        frequency: Duration(days: 1),
        inputData: {
          'id': notificationId,
          'title': notificationTitle,
          'body': notificationBody,
          'hour': scheduleTime.hour,
          'minute': scheduleTime.minute,
        },
      );
    }
  }
}
