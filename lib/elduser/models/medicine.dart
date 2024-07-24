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
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      quantity: map['quantity'] ?? 0,
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      shape: map['shape'] ?? '',
      color: map['color'] ?? '',
      scheduleTimes: (map['scheduleTimes'] as List?)
              ?.map((t) => (t as Timestamp).toDate())
              .toList() ??
          [],
      isBeforeFood: map['isBeforeFood'] ?? false,
    );
  }
}
