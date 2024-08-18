import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/pharmacy/model/pharmacist_order.dart';

class PharmacistOrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PharmacistOrderModel>> getOrders(String shopId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .where('shopId', isEqualTo: shopId)
          .orderBy('createdAt', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return []; // Return an empty list if no orders are found
      }

      return querySnapshot.docs
          .map((doc) => PharmacistOrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow; // Rethrow the error to be handled in the bloc
    }
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
}
