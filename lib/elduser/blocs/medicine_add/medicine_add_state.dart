import 'package:eldcare/elduser/blocs/presentation/models/medicine.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MedicineAddState extends Equatable {
  final String name;
  final String dosage;
  final String quantity;
  final int pillsPerDay;
  final List<TimeOfDay> pillTimes;
  final DateTime startDate;
  final DateTime endDate;
  final String shape;
  final Color color;

  MedicineAddState({
    this.name = '',
    this.dosage = '',
    this.quantity = '',
    this.pillsPerDay = 1,
    this.pillTimes = const [TimeOfDay(hour: 8, minute: 0)],
    DateTime? startDate,
    DateTime? endDate,
    this.shape = '',
    this.color = Colors.white,
  })  : startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now().add(const Duration(days: 30));

  factory MedicineAddState.fromMedicine(Medicine medicine) {
    return MedicineAddState(
      name: medicine.name,
      dosage: medicine.dosage,
      quantity: medicine.quantity,
      pillsPerDay: medicine.pillsPerDay,
      pillTimes: medicine.pillTimes,
      startDate: medicine.startDate,
      endDate: medicine.endDate,
      shape: medicine.shape,
      color: medicine.color,
    );
  }

  MedicineAddState copyWith({
    String? name,
    String? dosage,
    String? quantity,
    int? pillsPerDay,
    List<TimeOfDay>? pillTimes,
    DateTime? startDate,
    DateTime? endDate,
    String? shape,
    Color? color,
  }) {
    return MedicineAddState(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      quantity: quantity ?? this.quantity,
      pillsPerDay: pillsPerDay ?? this.pillsPerDay,
      pillTimes: pillTimes ?? this.pillTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      shape: shape ?? this.shape,
      color: color ?? this.color,
    );
  }

  @override
  List<Object> get props => [
        name,
        dosage,
        quantity,
        pillsPerDay,
        pillTimes,
        startDate,
        endDate,
        shape,
        color,
      ];
}
