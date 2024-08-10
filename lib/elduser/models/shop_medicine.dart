import 'package:cloud_firestore/cloud_firestore.dart';

class ShopMedicine {
  final String id;
  final String medicineId;
  final String medicineName;
  final int quantity;
  final double price;
  final DateTime expiryDate;
  final String supplier;
  final String lotNumber;
  final String category; // Add this line

  ShopMedicine({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.quantity,
    required this.price,
    required this.expiryDate,
    required this.supplier,
    required this.lotNumber,
    required this.category, // Add this line
  });

  factory ShopMedicine.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ShopMedicine(
      id: doc.id,
      medicineId: data['medicineId'] ?? '',
      medicineName: data['medicineName'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] ?? 0.0).toDouble(),
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      supplier: data['supplier'] ?? '',
      lotNumber: data['lotNumber'] ?? '',
      category: data['category'] ?? 'Uncategorized', // Add this line
    );
  }
}
