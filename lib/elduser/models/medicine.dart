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

  Medicine({
    this.id = '',
    required this.name,
    required this.dosage,
    required this.quantity,
    required this.startDate,
    required this.endDate,
    required this.shape,
    required this.color,
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
    );
  }
}
