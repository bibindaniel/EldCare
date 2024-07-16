import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'medicine_add_event.dart';
import 'medicine_add_state.dart';

class MedicineAddBloc extends Bloc<MedicineAddEvent, MedicineAddState> {
  MedicineAddBloc() : super(MedicineAddState()) {
    on<MedicineFieldChanged>(_onFieldChanged);
    on<MedicineSubmitted>(_onSubmitted);
  }

  void _onFieldChanged(
      MedicineFieldChanged event, Emitter<MedicineAddState> emit) {
    switch (event.field) {
      case 'name':
        emit(state.copyWith(name: event.value));
        break;
      case 'dosage':
        emit(state.copyWith(dosage: event.value));
        break;
      case 'quantity':
        emit(state.copyWith(quantity: event.value));
        break;
      case 'pillsPerDay':
        final newPillTimes = List.generate(
          event.value,
          (index) => TimeOfDay(hour: 8 + (index * 4), minute: 0),
        );
        emit(state.copyWith(pillsPerDay: event.value, pillTimes: newPillTimes));
        break;
      case 'pillTime':
        final newPillTimes = List<TimeOfDay>.from(state.pillTimes);
        newPillTimes[event.value['index']] = event.value['time'];
        emit(state.copyWith(pillTimes: newPillTimes));
        break;
      case 'startDate':
        emit(state.copyWith(startDate: event.value));
        break;
      case 'endDate':
        emit(state.copyWith(endDate: event.value));
        break;
      case 'shape':
        emit(state.copyWith(shape: event.value));
        break;
      case 'color':
        emit(state.copyWith(color: event.value));
        break;
    }
  }

  void _onSubmitted(MedicineSubmitted event, Emitter<MedicineAddState> emit) {
    // Here you would typically save the medicine data
    print('Medicine submitted: ${state.name}');
  }
}
