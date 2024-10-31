import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/order.dart';

enum OrderStatus {
  pending,
  confirmed,
  readyForPickup,
  assignedToDelivery,
  inTransit,
  completed,
  cancelled
}

class PharmacistOrderModel {
  final String id;
  final String customerId;
  final String shopId;
  final List<PharmacistOrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final String? deliveryAddress;
  final String? deliveryInstructions;
  String get formattedStatus {
    return status.toString().split('.').last;
  }

  String get formattedDate {
    return "${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}";
  }

  PharmacistOrderModel({
    required this.id,
    required this.customerId,
    required this.shopId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.deliveryAddress,
    this.deliveryInstructions,
  });

  factory PharmacistOrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PharmacistOrderModel(
      id: doc.id,
      customerId: _parseString(data['customerId']),
      shopId: _parseString(data['shopId']),
      items: _parseItems(data['items']),
      totalAmount: _parseDouble(data['totalAmount']),
      status: _parseOrderStatus(data['status']),
      createdAt: _parseDateTime(data['createdAt']),
      deliveryAddress: _parseString(data['deliveryAddress']),
      deliveryInstructions: _parseString(data['deliveryInstructions']),
    );
  }

  static String _parseString(dynamic value) {
    if (value is String) {
      return value;
    } else if (value is Map) {
      return value.toString();
    }
    return '';
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  static OrderStatus _parseOrderStatus(dynamic value) {
    if (value is String) {
      return OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.$value',
        orElse: () => OrderStatus.pending,
      );
    }
    return OrderStatus.pending;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return DateTime.now();
  }

  static List<PharmacistOrderItem> _parseItems(dynamic value) {
    if (value is List) {
      return value
          .map((item) =>
              PharmacistOrderItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'shopId': shopId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveryAddress': deliveryAddress,
      'deliveryInstructions': deliveryInstructions,
    };
  }

  static PharmacistOrderModel fromMedicineOrder(MedicineOrder order) {
    return PharmacistOrderModel(
      id: order.id,
      customerId: order.userId,
      shopId: order.shopId,
      items: order.items
          .map((item) => PharmacistOrderItem(
                medicineId: item.medicineId,
                medicineName: item.medicineName,
                quantity: item.quantity,
                price: item.price,
              ))
          .toList(),
      totalAmount: order.totalAmount,
      status: _convertStatus(order.status),
      createdAt: order.createdAt,
      deliveryAddress: order.deliveryAddress.toString(),
      deliveryInstructions: '', // Add this field to MedicineOrder if needed
    );
  }

  static OrderStatus _convertStatus(String status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'readyForPickup':
        return OrderStatus.readyForPickup;
      case 'assignedToDelivery':
        return OrderStatus.assignedToDelivery;
      case 'inTransit':
        return OrderStatus.inTransit;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

class PharmacistOrderItem {
  final String medicineId;
  final String medicineName;
  final int quantity;
  final double price;

  PharmacistOrderItem({
    required this.medicineId,
    required this.medicineName,
    required this.quantity,
    required this.price,
  });

  factory PharmacistOrderItem.fromMap(Map<String, dynamic> map) {
    return PharmacistOrderItem(
      medicineId: PharmacistOrderModel._parseString(map['medicineId']),
      medicineName: PharmacistOrderModel._parseString(map['medicineName']),
      quantity: map['quantity'] is int ? map['quantity'] : 0,
      price: PharmacistOrderModel._parseDouble(map['price']),
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
