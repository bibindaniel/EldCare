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
