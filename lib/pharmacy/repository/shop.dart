import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/pharmacy/model/shop.dart';

class ShopRepository {
  final FirebaseFirestore _firestore;

  ShopRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addShop(Shop shop) async {
    await _firestore.collection('shops').doc(shop.id).set(shop.toMap());
  }

  Future<void> updateShop(Shop shop) async {
    await _firestore.collection('shops').doc(shop.id).update(shop.toMap());
  }

  Stream<List<Shop>> getShops(String ownerId) {
    print('Fetching shops for owner: $ownerId');
    return _firestore
        .collection('shops')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      print('Received ${snapshot.docs.length} shops');
      return snapshot.docs.map((doc) => Shop.fromMap(doc.data())).toList();
    });
  }

  Future<List<Shop>> searchShopsByLocation(
      GeoPoint location, double radiusInKm) async {
    // This is a simple implementation. For more accurate results, you might want to use a geospatial database or service.
    final QuerySnapshot snapshot = await _firestore.collection('shops').get();

    List<Shop> nearbyShops = snapshot.docs
        .map((doc) => Shop.fromMap(doc.data() as Map<String, dynamic>))
        .where((shop) {
      double distance = _calculateDistance(location, shop.location);
      return distance <= radiusInKm;
    }).toList();

    return nearbyShops;
  }

  double _calculateDistance(GeoPoint point1, GeoPoint point2) {
    // Implement the Haversine formula to calculate distance between two points
    // This is a placeholder. You should implement the actual calculation.
    return 0.0;
  }
}
