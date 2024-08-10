import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineOrder {
  final String id;
  final String userId;
  final String shopId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  MedicineOrder({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory MedicineOrder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MedicineOrder(
      id: doc.id,
      userId: data['userId'] ?? '',
      shopId: data['shopId'] ?? '',
      items: (data['items'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'shopId': shopId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class OrderItem {
  final String medicineId;
  final String medicineName;
  final int quantity;
  final double price;

  OrderItem({
    required this.medicineId,
    required this.medicineName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'quantity': quantity,
      'price': price,
    };
  }
}
