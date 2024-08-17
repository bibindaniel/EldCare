import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id;
  final String name;
  final String categoryId;
  final String dosage;
  final String shopId; // Add this line
  final bool requiresPrescription; // Add this line

  Medicine({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.dosage,
    required this.shopId, // Add this line
    required this.requiresPrescription, // Add this line
  });

  factory Medicine.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Medicine(
      id: doc.id,
      name: data['name'] ?? '',
      categoryId: data['categoryId'] ?? '',
      dosage: data['dosage'] ?? '',
      shopId: data['shopId'] ?? '', // Add this line
      requiresPrescription:
          data['requiresPrescription'] ?? false, // Add this line
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'dosage': dosage,
      'shopId': shopId, // Add this line
      'requiresPrescription': requiresPrescription, // Add this line
    };
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? dosage,
    String? shopId, // Add this line
    bool? requiresPrescription, // Add this line
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      dosage: dosage ?? this.dosage,
      shopId: shopId ?? this.shopId, // Add this line
      requiresPrescription:
          requiresPrescription ?? this.requiresPrescription, // Add this line
    );
  }

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, categoryId: $categoryId, dosage: $dosage, shopId: $shopId, requiresPrescription: $requiresPrescription)';
  }
}
