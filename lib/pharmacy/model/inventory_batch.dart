import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryBatch {
  final String id;
  final String shopId;
  final String medicineId;
  final int quantity;
  final DateTime expiryDate;
  final String supplier;
  final String lotNumber;
  final double price;
  final String? medicineName;

  InventoryBatch({
    required this.id,
    required this.shopId,
    required this.medicineId,
    required this.quantity,
    required this.expiryDate,
    required this.supplier,
    required this.lotNumber,
    required this.price,
    this.medicineName,
  });

  factory InventoryBatch.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return InventoryBatch(
      id: doc.id,
      shopId: data['shopId'] ?? '',
      medicineId: data['medicineId'] ?? '',
      quantity: data['quantity'] ?? 0,
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      supplier: data['supplier'] ?? '',
      lotNumber: data['lotNumber'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      medicineName: data['medicineName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'medicineId': medicineId,
      'quantity': quantity,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'supplier': supplier,
      'lotNumber': lotNumber,
      'price': price,
      'medicineName': medicineName,
    };
  }

  InventoryBatch copyWith({
    String? id,
    String? shopId,
    String? medicineId,
    int? quantity,
    DateTime? expiryDate,
    String? supplier,
    String? lotNumber,
    double? price,
    String? medicineName,
  }) {
    return InventoryBatch(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      medicineId: medicineId ?? this.medicineId,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      supplier: supplier ?? this.supplier,
      lotNumber: lotNumber ?? this.lotNumber,
      price: price ?? this.price,
      medicineName: medicineName ?? this.medicineName,
    );
  }
}
