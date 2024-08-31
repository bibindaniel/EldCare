import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/delivery/model/delivery_order_model.dart';
import 'package:eldcare/pharmacy/model/pharmacist_order.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mailer/smtp_server.dart';

class DeliveryOrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _emailUsername;
  final String _emailPassword;

  DeliveryOrderRepository()
      : _emailUsername = dotenv.env['EMAIL_USERNAME'] ?? '',
        _emailPassword = dotenv.env['EMAIL_PASSWORD'] ?? '' {
    print('Email Username: $_emailUsername');
    print(
        'Email Password: ${_emailPassword.isNotEmpty ? '[SET]' : '[NOT SET]'}');
  }

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
      final verificationCode = _generateVerificationCode();
      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.inTransit.toString().split('.').last,
        'deliveryPersonId': deliveryPersonId,
        'verificationCode': verificationCode,
      });

      // Fetch the updated order
      DocumentSnapshot updatedDoc =
          await _firestore.collection('orders').doc(orderId).get();
      DeliveryOrderModel updatedOrder =
          DeliveryOrderModel.fromFirestore(updatedDoc);

      // Send verification code to customer
      await _sendVerificationCode(updatedOrder, verificationCode);

      return updatedOrder;
    } catch (e) {
      print('Error accepting order: $e');
      rethrow;
    }
  }

  String _generateVerificationCode() {
    return (100000 + Random().nextInt(900000)).toString(); // 6-digit code
  }

  Future<void> _sendVerificationCode(
      DeliveryOrderModel order, String code) async {
    final customerEmail = await _getCustomerEmail(order.customerId);
    print('Attempting to send email to: $customerEmail');

    if (_emailUsername.isEmpty || _emailPassword.isEmpty) {
      print(
          'Email credentials are not set. Please check your environment variables.');
      return;
    }

    final smtpServer = gmail(_emailUsername, _emailPassword);

    final message = mailer.Message()
      ..from = mailer.Address(_emailUsername, 'EldCare Delivery')
      ..recipients.add(customerEmail)
      ..subject = 'Your EldCare Delivery Verification Code'
      ..text = 'Your delivery verification code is: $code';

    try {
      final sendReport = await mailer.send(message, smtpServer);
      print('Verification code sent: ${sendReport.toString()}');
    } on mailer.MailerException catch (e) {
      print('Error sending verification code: ${e.toString()}');
      // You might want to handle this error more gracefully, e.g., by showing a message to the user
    }
  }

  Future<String> _getCustomerEmail(String customerId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(customerId).get();
    return userDoc.get('email') as String;
  }

  Future<bool> verifyDeliveryCode(String orderId, String enteredCode) async {
    DocumentSnapshot orderDoc =
        await _firestore.collection('orders').doc(orderId).get();
    return orderDoc.get('verificationCode') == enteredCode;
  }

  Future<void> markOrderAsDelivered(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': OrderStatus.completed.toString().split('.').last,
    });
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

  Future<void> cancelDelivery(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.readyForPickup.toString().split('.').last,
        'deliveryPersonId': null,
        'verificationCode': null,
      });
      print('Delivery canceled successfully');
    } catch (e) {
      print('Error canceling delivery: $e');
      rethrow;
    }
  }

  Future<void> sendTestEmail() async {
    if (_emailUsername.isEmpty || _emailPassword.isEmpty) {
      print('Email credentials are not set. Please check your .env file.');
      throw Exception('Email credentials are not set');
    }

    final smtpServer = gmail(_emailUsername, _emailPassword);

    final message = Message()
      ..from = Address(_emailUsername, 'EldCare Delivery')
      ..recipients.add(_emailUsername) // Sending to yourself for testing
      ..subject = 'Test Email from EldCare Delivery App'
      ..text = 'This is a test email sent from the EldCare Delivery app.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Test email sent: ${sendReport.toString()}');
    } on MailerException catch (e) {
      print('Error sending test email:');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      throw Exception('Failed to send test email: ${e.toString()}');
    } catch (e) {
      print('Unexpected error sending test email: $e');
      throw Exception('Unexpected error sending test email: $e');
    }
  }

  Future<List<DeliveryOrderModel>> getOrderHistory(
      String deliveryPersonId) async {
    try {
      final QuerySnapshot orderSnapshot = await _firestore
          .collection('orders')
          .where('deliveryPersonId', isEqualTo: deliveryPersonId)
          .orderBy('createdAt', descending: true)
          .get();

      return orderSnapshot.docs
          .map((doc) => DeliveryOrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching order history: $e');
      rethrow;
    }
  }
}
