import 'package:equatable/equatable.dart';
import 'package:eldcare/pharmacy/model/medicine.dart';

abstract class MedicineNameState extends Equatable {
  const MedicineNameState();

  @override
  List<Object> get props => [];
}

class MedicineInitial extends MedicineNameState {}

class MedicineLoading extends MedicineNameState {}

class MedicineLoaded extends MedicineNameState {
  final List<Medicine> medicines;

  const MedicineLoaded(this.medicines);

  @override
  List<Object> get props => [medicines];
}

class MedicineOperationSuccess extends MedicineNameState {
  final String message;

  const MedicineOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class MedicineError extends MedicineNameState {
  final String message;

  const MedicineError(this.message);

  @override
  List<Object> get props => [message];
}
