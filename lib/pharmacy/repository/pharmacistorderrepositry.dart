import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/pharmacy/model/pharmacist_order.dart';

class PharmacistOrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PharmacistOrderModel>> getOrdersStream(String shopId) {
    return _firestore
        .collection('orders')
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PharmacistOrderModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus.toString().split('.').last,
      });
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  Stream<List<PharmacistOrderModel>> getRecentOrders(String shopId,
      {int limit = 5}) {
    return _firestore
        .collection('orders')
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PharmacistOrderModel.fromFirestore(doc))
          .toList();
    });
  }
}
