abstract class MedicineAddEvent {}

class MedicineFieldChanged extends MedicineAddEvent {
  final String field;
  final dynamic value;

  MedicineFieldChanged(this.field, this.value);
}

class MedicineSubmitted extends MedicineAddEvent {}
