abstract class MedicineAddEvent {}

class MedicineFieldChanged extends MedicineAddEvent {
  final String field;
  final dynamic value;

  MedicineFieldChanged(this.field, this.value);
}

class MedicineFieldCompleted extends MedicineAddEvent {
  final String field;
  final dynamic value;

  MedicineFieldCompleted(this.field, this.value);

  List<Object?> get props => [field, value];
}

class MedicineSubmitted extends MedicineAddEvent {}

enum MedicineAddStatus { initial, submitting, success, failure }
