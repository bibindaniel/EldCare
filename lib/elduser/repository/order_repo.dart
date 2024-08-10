import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/order.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder(MedicineOrder order) async {
    try {
      await _firestore.collection('orders').add(order.toMap());
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Stream<List<MedicineOrder>> getOrdersForUser(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MedicineOrder.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<MedicineOrder>> getOrdersForShop(String shopId) {
    return _firestore
        .collection('orders')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MedicineOrder.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<MedicineOrder?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return MedicineOrder.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }
}
