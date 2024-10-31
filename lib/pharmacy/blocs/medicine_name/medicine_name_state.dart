part of 'medicine_name_bloc.dart';

abstract class MedicineNameState {}

class MedicineNameInitial extends MedicineNameState {}

class MedicineNameLoading extends MedicineNameState {}

class MedicineNameLoaded extends MedicineNameState {
  final List<Medicine> medicines;
  MedicineNameLoaded(this.medicines);
}

class MedicineOperationSuccess extends MedicineNameState {
  final String message;
  MedicineOperationSuccess(this.message);
}

class MedicineNameError extends MedicineNameState {
  final String message;
  MedicineNameError(this.message);
}
