import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/shoplisting.dart';
import 'package:eldcare/pharmacy/model/shop.dart';
import 'dart:math' show cos, sqrt, asin;

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
    final snapshot = await _firestore
        .collection('shops')
        .where('isVerified', isEqualTo: true)
        .get();

    final shops = snapshot.docs
        .map((doc) => VerifiedShopListing.fromShop(Shop.fromMap(doc.data())))
        .toList();

    return shops.where((shop) {
      final distance = _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          shop.location.latitude,
          shop.location.longitude);
      return distance <= radiusInKm;
    }).toList();
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    const c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
