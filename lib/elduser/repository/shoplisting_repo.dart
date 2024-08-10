import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/shoplisting.dart';
import 'package:eldcare/pharmacy/model/shop.dart';

class VerifiedShopListingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<VerifiedShopListing>> getVerifiedShops() {
    return _firestore
        .collection('shops')
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VerifiedShopListing.fromShop(Shop.fromMap(doc.data())))
          .toList();
    });
  }

  Future<List<VerifiedShopListing>> searchVerifiedShops(String query) async {
    final snapshot = await _firestore
        .collection('shops')
        .where('isVerified', isEqualTo: true)
        .get();

    final shops = snapshot.docs
        .map((doc) => VerifiedShopListing.fromShop(Shop.fromMap(doc.data())))
        .toList();

    return shops
        .where((shop) =>
            shop.name.toLowerCase().contains(query.toLowerCase()) ||
            shop.address.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<List<VerifiedShopListing>> getNearbyVerifiedShops(
      GeoPoint userLocation, double radiusInKm) async {
    // This is a simplified version. For accurate geoqueries, consider using a geospatial database or a specialized package.
    final snapshot = await _firestore
        .collection('shops')
        .where('isVerified', isEqualTo: true)
        .get();

    final shops = snapshot.docs
        .map((doc) => VerifiedShopListing.fromShop(Shop.fromMap(doc.data())))
        .toList();

    return shops.where((shop) {
      final distance = _calculateDistance(userLocation, shop.location);
      return distance <= radiusInKm;
    }).toList();
  }

  double _calculateDistance(GeoPoint point1, GeoPoint point2) {
    // Implement distance calculation logic here
    // You can use the Haversine formula or a package like 'geolocator'
    // This is a placeholder implementation
    return 0.0;
  }
}
