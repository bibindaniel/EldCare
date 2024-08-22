import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/delivery/model/delivery_order_model.dart';
import 'package:eldcare/pharmacy/model/pharmacist_order.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryOrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<DeliveryOrderModel>> getAvailableOrders(
      GeoPoint deliveryBoyLocation, double maxDistance) async {
    try {
      print('Fetching orders from Firestore...'); // Debug print
      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .where('status',
              isEqualTo: OrderStatus.readyForPickup.toString().split('.').last)
          .get();

      print(
          'Fetched ${querySnapshot.docs.length} documents from Firestore'); // Debug print

      List<DeliveryOrderModel> availableOrders = [];

      for (var doc in querySnapshot.docs) {
        try {
          DeliveryOrderModel order = DeliveryOrderModel.fromFirestore(doc);
          GeoPoint? customerLocation =
              _getCustomerLocation(order.deliveryAddress);
          if (customerLocation != null) {
            double distance =
                await _calculateDistance(deliveryBoyLocation, customerLocation);
            if (distance <= maxDistance) {
              order.distanceToCustomer = distance;
              availableOrders.add(order);
            }
          }
        } catch (e) {
          print('Error processing order ${doc.id}: $e');
        }
      }

      print('${availableOrders.length} orders within range'); // Debug print
      return availableOrders;
    } catch (e) {
      print('Error fetching available orders: $e');
      rethrow;
    }
  }

  GeoPoint? _getCustomerLocation(Map<String, dynamic> deliveryAddress) {
    try {
      var address = deliveryAddress['address'] as Map<String, dynamic>;
      var location = address['location'];
      if (location is GeoPoint) {
        return location;
      }
    } catch (e) {
      print('Error getting customer location: $e');
    }
    return null;
  }

  Future<double> _calculateDistance(GeoPoint point1, GeoPoint point2) async {
    return await Geolocator.distanceBetween(
          point1.latitude,
          point1.longitude,
          point2.latitude,
          point2.longitude,
        ) /
        1000; // Convert meters to kilometers
  }

  GeoPoint? _getOrderLocation(DeliveryOrderModel order) {
    try {
      var address = order.deliveryAddress['address'] as Map<String, dynamic>;
      var location = address['location'];
      if (location is GeoPoint) {
        return location;
      }
    } catch (e) {
      print('Error getting order location: $e');
    }
    return null;
  }

  bool _isWithinRange(
      GeoPoint shopLocation, GeoPoint deliveryBoyLocation, double maxDistance) {
    // Debug print
    print(
        'Distance calculation: shop: $shopLocation, delivery: $deliveryBoyLocation, max: $maxDistance');

    double lat1 = shopLocation.latitude;
    double lon1 = shopLocation.longitude;
    double lat2 = deliveryBoyLocation.latitude;
    double lon2 = deliveryBoyLocation.longitude;

    // Placeholder distance calculation (not accurate, replace with proper implementation)
    double distance =
        ((lat2 - lat1).abs() + (lon2 - lon1).abs()) * 111; // 111 km per degree

    // Debug print
    print('Calculated distance: $distance km');

    bool result = distance <= maxDistance;

    // Debug print
    print('Is within range: $result');

    return result;
  }

  Future<DeliveryOrderModel> acceptOrder(
      String orderId, String deliveryPersonId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.inTransit.toString().split('.').last,
        'deliveryPersonId': deliveryPersonId,
      });

      // Fetch and return the updated order
      DocumentSnapshot updatedDoc =
          await _firestore.collection('orders').doc(orderId).get();
      return DeliveryOrderModel.fromFirestore(updatedDoc);
    } catch (e) {
      print('Error accepting order: $e');
      rethrow;
    }
  }

  Future<DeliveryOrderModel?> getCurrentDelivery(
      String deliveryPersonId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .where('deliveryPersonId', isEqualTo: deliveryPersonId)
          .where('status',
              isEqualTo: OrderStatus.inTransit.toString().split('.').last)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return DeliveryOrderModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error fetching current delivery: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> getDeliverySummary(String deliveryPersonId) async {
    try {
      final QuerySnapshot completedOrders = await _firestore
          .collection('orders')
          .where('deliveryPersonId', isEqualTo: deliveryPersonId)
          .where('status',
              isEqualTo: OrderStatus.completed.toString().split('.').last)
          .get();

      final QuerySnapshot pendingOrders = await _firestore
          .collection('orders')
          .where('deliveryPersonId', isEqualTo: deliveryPersonId)
          .where('status',
              isEqualTo: OrderStatus.inTransit.toString().split('.').last)
          .get();

      return {
        'total': completedOrders.docs.length + pendingOrders.docs.length,
        'completed': completedOrders.docs.length,
        'pending': pendingOrders.docs.length,
      };
    } catch (e) {
      print('Error fetching delivery summary: $e');
      return {'total': 0, 'completed': 0, 'pending': 0};
    }
  }
}
