part of 'medicine_name_bloc.dart';

abstract class MedicineNameEvent {}

class LoadMedicines extends MedicineNameEvent {
  final String shopId;
  LoadMedicines(this.shopId);
}

class AddMedicine extends MedicineNameEvent {
  final Medicine medicine;
  AddMedicine(this.medicine);
}

class UpdateMedicine extends MedicineNameEvent {
  final Medicine medicine;
  UpdateMedicine(this.medicine);
}

class DeleteMedicine extends MedicineNameEvent {
  final String medicineId;
  final String shopId;
  DeleteMedicine(this.medicineId, this.shopId);
}

class SearchMedicines extends MedicineNameEvent {
  final String query;
  final String shopId;
  SearchMedicines(this.query, this.shopId);
}
