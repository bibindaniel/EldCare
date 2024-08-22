import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/delivary_address.dart';

class MedicineOrder {
  final String id;
  final String userId;
  final String shopId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final String? prescriptionUrl;
  final DeliveryAddress deliveryAddress;
  final String phoneNumber;
  final String paymentId;

  MedicineOrder({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.prescriptionUrl,
    required this.deliveryAddress,
    required this.phoneNumber,
    double? deliveryCharge,
    required this.paymentId,
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
      prescriptionUrl: data['prescriptionUrl'],
      deliveryAddress: DeliveryAddress.fromMap(data['deliveryAddress'] ?? {},
          id: data['deliveryAddress']?['id']),
      phoneNumber: data['phoneNumber'] ?? '',
      paymentId: data['paymentId'] ?? '',
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
      'prescriptionUrl': prescriptionUrl,
      'deliveryAddress': deliveryAddress.toMap(),
      'phoneNumber': phoneNumber,
      'paymentId': paymentId,
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
