import 'package:eldcare/pharmacy/blocs/medicine_name/medicine_name_event.dart';
import 'package:eldcare/pharmacy/blocs/medicine_name/medicine_name_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/pharmacy/model/medicine.dart';
import 'package:eldcare/pharmacy/repository/medicine_repositry.dart';

class MedicineNameBloc extends Bloc<MedicineNameEvent, MedicineNameState> {
  final MedicineNameRepository repository;
  Stream<List<Medicine>>? _medicineStream;

  MedicineNameBloc({required this.repository}) : super(MedicineInitial()) {
    _startMedicineStream();
    on<LoadMedicines>(_onLoadMedicines);
    on<AddMedicine>(_onAddMedicine);
    on<UpdateMedicine>(_onUpdateMedicine);
    on<DeleteMedicine>(_onDeleteMedicine);
    on<SearchMedicines>(_onSearchMedicines);
  }

  void _startMedicineStream() {
    _medicineStream = repository.getMedicinesStream();
    _medicineStream?.listen((medicines) {
      add(LoadMedicines());
    });
  }

  Future<void> _onLoadMedicines(
      LoadMedicines event, Emitter<MedicineNameState> emit) async {
    emit(MedicineLoading());
    try {
      final medicines = await repository.getMedicinesStream().first;
      emit(MedicineLoaded(medicines));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  Future<void> _onAddMedicine(
      AddMedicine event, Emitter<MedicineNameState> emit) async {
    try {
      await repository.addMedicine(event.medicine);
      // The stream listener will trigger LoadMedicines
      emit(const MedicineOperationSuccess('Medicine added successfully'));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  Future<void> _onUpdateMedicine(
      UpdateMedicine event, Emitter<MedicineNameState> emit) async {
    try {
      await repository.updateMedicine(event.medicine);
      // The stream listener will trigger LoadMedicines
      emit(const MedicineOperationSuccess('Medicine updated successfully'));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  Future<void> _onDeleteMedicine(
      DeleteMedicine event, Emitter<MedicineNameState> emit) async {
    try {
      await repository.deleteMedicine(event.id);
      // The stream listener will trigger LoadMedicines
      emit(const MedicineOperationSuccess('Medicine deleted successfully'));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  Future<void> _onSearchMedicines(
      SearchMedicines event, Emitter<MedicineNameState> emit) async {
    try {
      final medicines = await repository.searchMedicines(event.query);
      emit(MedicineLoaded(medicines));
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }
}
