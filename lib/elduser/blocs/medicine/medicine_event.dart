part of 'medicine_bloc.dart';

abstract class MedicineEvent {}

class AddMedicine extends MedicineEvent {
  final Medicine medicine;
  AddMedicine(this.medicine);
}

class UpdateMedicineSchedule extends MedicineEvent {
  final Medicine medicine;
  final List<DateTime> scheduleTimes;
  final bool isBeforeFood;
  UpdateMedicineSchedule(this.medicine, this.scheduleTimes, this.isBeforeFood);
}

class AddAndScheduleMedicine extends MedicineEvent {
  final Medicine medicine;

  AddAndScheduleMedicine({required this.medicine});
}

class FetchMedicinesForDate extends MedicineEvent {
  final DateTime date;

  FetchMedicinesForDate(this.date);
}

class FetchCompletedMedicines extends MedicineEvent {}

class FetchUpcomingMedicines extends MedicineEvent {}

class UpdateMedicine extends MedicineEvent {
  final Medicine medicine;
  UpdateMedicine({required this.medicine});
}

class RemoveMedicine extends MedicineEvent {
  final String medicineId;
  RemoveMedicine({required this.medicineId});
}
