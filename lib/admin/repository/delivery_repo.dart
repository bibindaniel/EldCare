import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/admin/model/delivery_charges.dart';

class DeliveryChargesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveDeliveryCharges(DeliveryChargesModel charges) async {
    await _firestore
        .collection('settings')
        .doc('delivery_charges')
        .set(charges.toJson());
  }

  Future<DeliveryChargesModel> getDeliveryCharges() async {
    final doc =
        await _firestore.collection('settings').doc('delivery_charges').get();
    if (doc.exists) {
      return DeliveryChargesModel.fromJson(doc.data()!);
    } else {
      return DeliveryChargesModel(
          baseCharge: 0, perKmCharge: 0, minimumOrderValue: 0);
    }
  }
}
