import 'package:flutter/material.dart';

class Medicine {
  final String name;
  final String dosage;
  final String quantity;
  final int pillsPerDay;
  final List<TimeOfDay> pillTimes;
  final DateTime startDate;
  final DateTime endDate;
  final String shape;
  final Color color;

  Medicine(
      {required this.name,
      required this.dosage,
      required this.quantity,
      required this.pillsPerDay,
      required this.pillTimes,
      required this.startDate,
      required this.endDate,
      required this.shape,
      required this.color});
}
