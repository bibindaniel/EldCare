import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/pharmacy/model/shop.dart';

class ShopRepository {
  final FirebaseFirestore _firestore;

  ShopRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Shop>> getAllShops() async {
    try {
      final snapshot = await _firestore.collection('shops').get();
      return snapshot.docs.map((doc) => Shop.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to load shops: $e');
    }
  }

  Future<void> approveShop(String shopId) async {
    try {
      await _firestore.collection('shops').doc(shopId).update({
        'isVerified': true,
      });
    } catch (e) {
      throw Exception('Failed to approve shop: $e');
    }
  }

  Future<void> rejectShop(String shopId) async {
    try {
      await _firestore.collection('shops').doc(shopId).delete();
    } catch (e) {
      throw Exception('Failed to reject shop: $e');
    }
  }
}
