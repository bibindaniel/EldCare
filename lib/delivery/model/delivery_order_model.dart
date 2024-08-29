import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/pharmacy/model/pharmacist_order.dart';

class DeliveryOrderModel {
  final String id;
  final String shopId;
  final String customerId;
  final Map<String, dynamic> deliveryAddress;
  final String? deliveryInstructions;
  final OrderStatus status;
  final DateTime createdAt;
  final GeoPoint? shopLocation;
  final double totalAmount;
  double? distanceToCustomer;
  final String? deliveryPersonId;
  final String? verificationCode;

  DeliveryOrderModel({
    required this.id,
    required this.shopId,
    required this.customerId,
    required this.deliveryAddress,
    this.deliveryInstructions,
    required this.status,
    required this.createdAt,
    this.shopLocation,
    required this.totalAmount,
    this.distanceToCustomer,
    this.deliveryPersonId,
    this.verificationCode,
  });

  factory DeliveryOrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    print('Parsing document ${doc.id}: ${data.toString()}'); // Debug print

    return DeliveryOrderModel(
      id: doc.id,
      shopId: _parseString(data['shopId']),
      customerId:
          _parseString(data['userId']), // Changed from 'customerId' to 'userId'
      deliveryAddress: data['deliveryAddress'] as Map<String, dynamic>,
      deliveryInstructions: data['deliveryInstructions'] as String?,
      status: _parseOrderStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      shopLocation: _parseGeoPoint(data['shopLocation']),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryPersonId: data['deliveryPersonId'] as String?,
      verificationCode: data['verificationCode'] as String?,
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

  static OrderStatus _parseOrderStatus(dynamic value) {
    if (value is String) {
      return OrderStatus.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
        orElse: () => OrderStatus.pending,
      );
    }
    return OrderStatus.pending;
  }

  static GeoPoint? _parseGeoPoint(dynamic value) {
    if (value is GeoPoint) {
      return value;
    } else if (value is Map<String, dynamic> && value.containsKey('location')) {
      var location = value['location'];
      if (location is GeoPoint) {
        return location;
      }
    }
    return null;
  }

  @override
  String toString() {
    return 'DeliveryOrderModel(id: $id, shopId: $shopId, customerId: $customerId, deliveryAddress: $deliveryAddress, status: $status, totalAmount: $totalAmount, deliveryPersonId: $deliveryPersonId)';
  }

  // Add a method to create a copy of the order with updated fields
  DeliveryOrderModel copyWith({
    String? id,
    String? shopId,
    String? customerId,
    Map<String, dynamic>? deliveryAddress,
    String? deliveryInstructions,
    OrderStatus? status,
    DateTime? createdAt,
    GeoPoint? shopLocation,
    double? totalAmount,
    double? distanceToCustomer,
    String? deliveryPersonId,
    String? verificationCode,
  }) {
    return DeliveryOrderModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      customerId: customerId ?? this.customerId,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      shopLocation: shopLocation ?? this.shopLocation,
      totalAmount: totalAmount ?? this.totalAmount,
      distanceToCustomer: distanceToCustomer ?? this.distanceToCustomer,
      deliveryPersonId: deliveryPersonId ?? this.deliveryPersonId,
      verificationCode: verificationCode ?? this.verificationCode,
    );
  }
}
