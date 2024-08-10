import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id;
  final String name;
  final String categoryId;
  final String dosage;

  Medicine({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.dosage,
  });

  factory Medicine.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Medicine(
      id: doc.id,
      name: data['name'] ?? '',
      categoryId: data['categoryId'] ?? '',
      dosage: data['dosage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'dosage': dosage,
    };
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? dosage,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      dosage: dosage ?? this.dosage,
    );
  }

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, categoryId: $categoryId, dosage: $dosage)';
  }
}
