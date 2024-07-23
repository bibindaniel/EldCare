part of 'medicine_bloc.dart';

abstract class MedicineState {}

class MedicineInitial extends MedicineState {}

class MedicineLoading extends MedicineState {}

class MedicineSuccess extends MedicineState {
  get medicine => null;
}

class MedicineError extends MedicineState {
  final String error;
  MedicineError(this.error);
}

class MedicinesLoaded extends MedicineState {
  final List<Medicine> medicines;

  MedicinesLoaded(this.medicines);
}
