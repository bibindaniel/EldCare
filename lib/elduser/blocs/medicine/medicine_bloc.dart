import 'package:eldcare/elduser/models/medicine.dart';
import 'package:eldcare/elduser/repository/medicine_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'medicine_event.dart';
part 'medicine_state.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final MedicineRepository _repository = MedicineRepository();

  MedicineBloc() : super(MedicineInitial()) {
    on<AddAndScheduleMedicine>(_onAddAndScheduleMedicine);
    on<FetchMedicinesForDate>(_onFetchMedicinesForDate);
  }

  void _onAddAndScheduleMedicine(
      AddAndScheduleMedicine event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      await _repository.addMedicine(event.medicine);
      emit(MedicineSuccess());
    } catch (e) {
      print('Error adding medicine: $e');
      emit(MedicineError('Failed to add medicine: ${e.toString()}'));
    }
  }

  void _onFetchMedicinesForDate(
      FetchMedicinesForDate event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      final medicines = await _repository.getMedicinesForDate(event.date);
      print('Fetched medicines: $medicines');
      emit(MedicinesLoaded(medicines));
    } catch (e) {
      print('Error fetching medicines: $e');
      emit(MedicineError(e.toString()));
    }
  }
}
