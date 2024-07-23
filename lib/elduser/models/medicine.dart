import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id;
  final String name;
  final String dosage;
  final int quantity;
  final DateTime startDate;
  final DateTime endDate;
  final String shape;
  final String color;
  final List<DateTime> scheduleTimes;
  final bool isBeforeFood;

  Medicine({
    this.id = '',
    required this.name,
    required this.dosage,
    required this.quantity,
    required this.startDate,
    required this.endDate,
    required this.shape,
    required this.color,
    required this.scheduleTimes,
    required this.isBeforeFood,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'quantity': quantity,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'shape': shape,
      'color': color,
      'scheduleTimes': scheduleTimes.map((t) => Timestamp.fromDate(t)).toList(),
      'isBeforeFood': isBeforeFood,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map, String id) {
    return Medicine(
      id: id,
      name: map['name'],
      dosage: map['dosage'],
      quantity: map['quantity'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      shape: map['shape'],
      color: map['color'],
      scheduleTimes: (map['scheduleTimes'] as List)
          .map((t) => (t as Timestamp).toDate())
          .toList(),
      isBeforeFood: map['isBeforeFood'],
    );
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    int? quantity,
    DateTime? startDate,
    DateTime? endDate,
    String? shape,
    String? color,
    List<DateTime>? scheduleTimes,
    bool? isBeforeFood,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      quantity: quantity ?? this.quantity,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      shape: shape ?? this.shape,
      color: color ?? this.color,
      scheduleTimes: scheduleTimes ?? this.scheduleTimes,
      isBeforeFood: isBeforeFood ?? this.isBeforeFood,
    );
  }
}
