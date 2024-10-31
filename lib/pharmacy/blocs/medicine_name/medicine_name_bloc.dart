import 'package:eldcare/pharmacy/repository/medicine_repositry.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/pharmacy/model/medicine.dart';

part 'medicine_name_event.dart';
part 'medicine_name_state.dart';

class MedicineNameBloc extends Bloc<MedicineNameEvent, MedicineNameState> {
  final MedicineRepository _medicineRepository;

  MedicineNameBloc(
      {required MedicineRepository medicineRepository,
      required MedicineRepository repository})
      : _medicineRepository = medicineRepository,
        super(MedicineNameInitial()) {
    on<LoadMedicines>(_onLoadMedicines);
    on<AddMedicine>(_onAddMedicine);
    on<UpdateMedicine>(_onUpdateMedicine);
    on<DeleteMedicine>(_onDeleteMedicine);
    on<SearchMedicines>(_onSearchMedicines);
  }

  void _onLoadMedicines(
      LoadMedicines event, Emitter<MedicineNameState> emit) async {
    emit(MedicineNameLoading());
    try {
      await emit.forEach(
        _medicineRepository.getMedicinesStream(event.shopId),
        onData: (List<Medicine> medicines) => MedicineNameLoaded(medicines),
        onError: (error, stackTrace) => MedicineNameError(error.toString()),
      );
    } catch (e) {
      emit(MedicineNameError(e.toString()));
    }
  }

  void _onAddMedicine(
      AddMedicine event, Emitter<MedicineNameState> emit) async {
    try {
      await _medicineRepository.addMedicine(event.medicine);
      emit(MedicineOperationSuccess('Medicine added successfully'));
    } catch (e) {
      emit(MedicineNameError(e.toString()));
    }
  }

  void _onUpdateMedicine(
      UpdateMedicine event, Emitter<MedicineNameState> emit) async {
    try {
      await _medicineRepository.updateMedicine(event.medicine);
      emit(MedicineOperationSuccess('Medicine updated successfully'));
    } catch (e) {
      emit(MedicineNameError(e.toString()));
    }
  }

  void _onDeleteMedicine(
      DeleteMedicine event, Emitter<MedicineNameState> emit) async {
    try {
      await _medicineRepository.deleteMedicine(event.medicineId, event.shopId);
      emit(MedicineOperationSuccess('Medicine deleted successfully'));
    } catch (e) {
      emit(MedicineNameError(e.toString()));
    }
  }

  void _onSearchMedicines(
      SearchMedicines event, Emitter<MedicineNameState> emit) async {
    emit(MedicineNameLoading());
    try {
      final medicines =
          await _medicineRepository.searchMedicines(event.query, event.shopId);
      emit(MedicineNameLoaded(medicines));
    } catch (e) {
      emit(MedicineNameError(e.toString()));
    }
  }
}
