import 'package:cloud_firestore/cloud_firestore.dart';

class ShopMedicine {
  final String id;
  final String medicineId;
  String? medicineName;
  String? category;
  final int quantity;
  final double price;
  final DateTime expiryDate;
  final String supplier;
  final String lotNumber;
  String? dosage;

  ShopMedicine({
    required this.id,
    required this.medicineId,
    this.medicineName,
    this.category,
    required this.quantity,
    required this.price,
    required this.expiryDate,
    required this.supplier,
    required this.lotNumber,
    this.dosage,
  });

  factory ShopMedicine.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShopMedicine(
      id: doc.id,
      medicineId: data['medicineId'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] ?? 0.0).toDouble(),
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      supplier: data['supplier'] ?? '',
      lotNumber: data['lotNumber'] ?? '',
    );
  }
}
