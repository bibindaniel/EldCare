import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/delivary_address.dart';

class DeliveryAddressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DeliveryAddress>> getDeliveryAddresses(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('delivery_addresses')
        .get();

    return querySnapshot.docs
        .map((doc) => DeliveryAddress.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  Future<void> addDeliveryAddress(
      String userId, DeliveryAddress address) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('delivery_addresses')
        .add(address.toMap());
  }

  Future<void> deleteDeliveryAddress(String userId, String addressId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('delivery_addresses')
        .doc(addressId)
        .delete();
  }

  Future<void> updateDeliveryAddress(
      String userId, DeliveryAddress address) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('delivery_addresses')
        .doc(address.id)
        .update(address.toMap());
  }

  Future<void> removeDeliveryAddress(String userId, String addressId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('delivery_addresses')
        .doc(addressId)
        .delete();
  }
}
