import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'medicine_add_event.dart';
import 'medicine_add_state.dart';

class MedicineAddBloc extends Bloc<MedicineAddEvent, MedicineAddState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MedicineAddBloc() : super(MedicineAddState()) {
    on<MedicineFieldChanged>(_onFieldChanged);
    on<MedicineFieldCompleted>(_onFieldCompleted);
    on<MedicineSubmitted>(_onSubmitted);
  }
  void _onFieldChanged(
      MedicineFieldChanged event, Emitter<MedicineAddState> emit) {
    switch (event.field) {
      case 'pillsPerDay':
        final newPillsPerDay = int.tryParse(event.value) ?? 1;
        final newPillTimes = List.generate(
          newPillsPerDay,
          (index) => index < state.pillTimes.length
              ? state.pillTimes[index]
              : TimeOfDay(hour: 8 + (index * 4) % 24, minute: 0),
        );
        emit(state.copyWith(
            pillsPerDay: newPillsPerDay, pillTimes: newPillTimes));
        break;
      case 'pillTime':
        final newPillTimes = List<TimeOfDay>.from(state.pillTimes);
        newPillTimes[event.value['index']] = event.value['time'];
        emit(state.copyWith(pillTimes: newPillTimes));
        break;
      case 'shape':
        emit(state.copyWith(shape: event.value));
        break;
      case 'color':
        emit(state.copyWith(color: event.value));
        break;
    }
  }

  void _onFieldCompleted(
      MedicineFieldCompleted event, Emitter<MedicineAddState> emit) {
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
      case 'startDate':
        emit(state.copyWith(startDate: event.value));
        break;
      case 'endDate':
        emit(state.copyWith(endDate: event.value));
        break;
      // Add other cases here for fields that use delayed update
    }
  }

  Future<void> _onSubmitted(
      MedicineSubmitted event, Emitter<MedicineAddState> emit) async {
    print('Submitting medicine...');
    emit(state.copyWith(status: MedicineAddStatus.submitting));
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final medicineData = {
        'name': state.name,
        'dosage': state.dosage,
        'quantity': state.quantity,
        'pillsPerDay': state.pillsPerDay,
        'pillTimes': state.pillTimes
            .map((time) => '${time.hour}:${time.minute}')
            .toList(),
        'startDate': state.startDate.toIso8601String(),
        'endDate': state.endDate.toIso8601String(),
        'shape': state.shape,
        'color': state.color.value,
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medicines')
          .add(medicineData);

      emit(state.copyWith(status: MedicineAddStatus.success));
    } catch (e) {
      print('Error submitting medicine: $e');
      emit(state.copyWith(
          status: MedicineAddStatus.failure, error: e.toString()));
    }
  }
}
