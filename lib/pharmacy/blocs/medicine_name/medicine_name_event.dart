import 'package:equatable/equatable.dart';
import 'package:eldcare/pharmacy/model/medicine.dart';

abstract class MedicineNameEvent extends Equatable {
  const MedicineNameEvent();

  @override
  List<Object> get props => [];
}

class LoadMedicines extends MedicineNameEvent {}

class AddMedicine extends MedicineNameEvent {
  final Medicine medicine;

  const AddMedicine(this.medicine);

  @override
  List<Object> get props => [medicine];
}

class UpdateMedicine extends MedicineNameEvent {
  final Medicine medicine;

  const UpdateMedicine(this.medicine);

  @override
  List<Object> get props => [medicine];
}

class DeleteMedicine extends MedicineNameEvent {
  final String id;

  const DeleteMedicine(this.id);

  @override
  List<Object> get props => [id];
}

class SearchMedicines extends MedicineNameEvent {
  final String query;

  const SearchMedicines(this.query);

  @override
  List<Object> get props => [query];
}
