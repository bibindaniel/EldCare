import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String shopId; // Add this line

  Category({
    required this.id,
    required this.name,
    required this.shopId, // Add this line
  });

  factory Category.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      shopId: data['shopId'] ?? '', // Add this line
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'shopId': shopId, // Add this line
    };
  }
}
