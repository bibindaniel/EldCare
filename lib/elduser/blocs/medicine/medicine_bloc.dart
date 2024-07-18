import 'package:eldcare/elduser/models/medicine.dart';
import 'package:eldcare/elduser/repository/medicine_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'medicine_event.dart';
part 'medicine_state.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final MedicineRepository _repository = MedicineRepository();

  MedicineBloc() : super(MedicineInitial()) {
    on<AddMedicine>(_onAddMedicine);
    on<UpdateMedicineSchedule>(_onUpdateMedicineSchedule);
  }

  void _onAddMedicine(AddMedicine event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      await _repository.addMedicine(event.medicine);
      emit(MedicineSuccess());
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  void _onUpdateMedicineSchedule(
      UpdateMedicineSchedule event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    try {
      await _repository.updateMedicineSchedule(
          event.medicine, event.scheduleTimes, event.isBeforeFood);
      emit(MedicineSuccess());
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }
}
