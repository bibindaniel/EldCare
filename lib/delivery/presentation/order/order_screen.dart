import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/delivery/blocs/delivery_order/delivery_order_bloc.dart';
import 'package:eldcare/delivery/model/delivery_order_model.dart';
import 'package:eldcare/pharmacy/model/pharmacist_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<DeliveryOrderBloc>()
          .add(FetchCurrentDelivery(deliveryPersonId: authState.user.uid));
      _fetchLocationAndOrders();
      context
          .read<DeliveryOrderBloc>()
          .add(FetchOrderHistory(authState.user.uid));
    }
  }

  Future<void> _fetchLocationAndOrders() async {
    try {
      Position position = await _determinePosition();
      context.read<DeliveryOrderBloc>().add(FetchAvailableOrders(
            deliveryBoyLocation:
                GeoPoint(position.latitude, position.longitude),
            maxDistance: 10.0,
          ));
    } catch (e) {
      print('Error in _fetchLocationAndOrders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location: $e')),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await openAppSettings();
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await openAppSettings();
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders', style: AppFonts.headline4Light),
        backgroundColor: kPrimaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchOrders(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentDeliverySection(),
              _buildAvailableOrdersSection(),
              _buildOrderHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentDeliverySection() {
    return BlocBuilder<DeliveryOrderBloc, DeliveryOrderState>(
      builder: (context, state) {
        if (state is DeliveryOrderLoaded && state.currentDelivery != null) {
          return _buildSection(
            title: "Current Delivery",
            child: _buildCurrentDeliveryCard(state.currentDelivery!),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAvailableOrdersSection() {
    return BlocBuilder<DeliveryOrderBloc, DeliveryOrderState>(
      builder: (context, state) {
        if (state is DeliveryOrderLoaded) {
          return _buildSection(
            title: "Available Orders",
            child: Column(
              children:
                  state.orders.map((order) => _buildOrderItem(order)).toList(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrderHistorySection() {
    return BlocBuilder<DeliveryOrderBloc, DeliveryOrderState>(
      builder: (context, state) {
        if (state is DeliveryOrderLoaded && state.orderHistory.isNotEmpty) {
          return _buildSection(
            title: "Order History",
            child: Column(
              children: state.orderHistory
                  .map((order) => _buildOrderItem(order))
                  .toList(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppFonts.headline5),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildCurrentDeliveryCard(DeliveryOrderModel currentDelivery) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${currentDelivery.id.substring(0, 8)}...',
                  style: AppFonts.headline5.copyWith(color: kPrimaryColor),
                ),
                Text(
                  '₹${currentDelivery.totalAmount.toStringAsFixed(2)}',
                  style: AppFonts.headline5.copyWith(color: kSecondaryColor),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery Address', style: AppFonts.cardSubtitle),
                const SizedBox(height: 8),
                _buildAddressDetails(currentDelivery.deliveryAddress),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      icon: Icons.navigation,
                      label: 'Navigate',
                      color: kPrimaryColor,
                      onPressed: () => _handleNavigation(currentDelivery),
                    ),
                    _buildActionButton(
                      icon: Icons.check_circle,
                      label: 'Deliver',
                      color: kSuccessColor,
                      onPressed: () =>
                          _showVerificationCodeDialog(currentDelivery),
                    ),
                    _buildActionButton(
                      icon: Icons.cancel,
                      label: 'Cancel',
                      color: kErrorColor,
                      onPressed: () =>
                          _showCancelDeliveryDialog(currentDelivery),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(DeliveryOrderModel order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: kLightBackgroundColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text('Order #${order.id.substring(0, 8)}...',
            style: AppFonts.bodyText1.copyWith(color: kPrimaryColor)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$${order.totalAmount.toStringAsFixed(2)}',
                style: AppFonts.bodyText2.copyWith(color: kSecondaryColor)),
            if (order.distanceToCustomer != null)
              Text(
                  'Distance: ${order.distanceToCustomer!.toStringAsFixed(2)} km',
                  style: AppFonts.bodyText2.copyWith(color: kAccentColor)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery Address:',
                    style: AppFonts.bodyText1.copyWith(
                        fontWeight: FontWeight.bold, color: kDarkTextColor)),
                const SizedBox(height: 8),
                _buildAddressDetails(order.deliveryAddress),
                const SizedBox(height: 16),
                Text('Order Status: ${order.status.toString().split('.').last}',
                    style: AppFonts.bodyText2.copyWith(color: kSecondaryColor)),
                const SizedBox(height: 16),
                if (order.status == OrderStatus.readyForPickup)
                  ElevatedButton(
                    onPressed: () => _acceptOrder(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: kWhiteColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Accept Order'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDetails(Map<String, dynamic> deliveryAddress) {
    final address = deliveryAddress['address'] as Map<String, dynamic>?;
    if (address == null) {
      return const Text('Address details not available',
          style: AppFonts.bodyText2);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(address['houseName'] ?? '', style: AppFonts.bodyText2),
        Text(address['street'] ?? '', style: AppFonts.bodyText2),
        Text(
            '${address['city'] ?? ''}, ${address['state'] ?? ''} ${address['postalCode'] ?? ''}',
            style: AppFonts.bodyText2),
        const SizedBox(height: 8),
        Text('Label: ${deliveryAddress['label'] ?? ''}',
            style: AppFonts.bodyText2.copyWith(fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          onPressed: onPressed,
          iconSize: 32,
        ),
        Text(
          label,
          style: AppFonts.caption.copyWith(color: color),
        ),
      ],
    );
  }

  void _showVerificationCodeDialog(DeliveryOrderModel currentDelivery) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String enteredCode = '';
        return BlocListener<DeliveryOrderBloc, DeliveryOrderState>(
          listener: (context, state) {
            if (state is DeliveryCodeVerificationSuccess) {
              Navigator.of(dialogContext).pop(); // Close the dialog on success
            }
            // Don't close the dialog for failure case
          },
          child: AlertDialog(
            title: const Text('Enter Verification Code'),
            content: TextField(
              onChanged: (value) => enteredCode = value,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Enter 6-digit code"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              TextButton(
                child: const Text('Verify'),
                onPressed: () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is Authenticated) {
                    context.read<DeliveryOrderBloc>().add(VerifyDeliveryCode(
                        currentDelivery.id, enteredCode, authState.user.uid));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('You need to be logged in to verify orders'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    Navigator.of(dialogContext).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelDeliveryDialog(DeliveryOrderModel currentDelivery) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Delivery'),
          content: const Text('Are you sure you want to cancel this delivery?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  context.read<DeliveryOrderBloc>().add(
                      CancelDelivery(currentDelivery.id, authState.user.uid));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'You need to be logged in to cancel deliveries')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleNavigation(DeliveryOrderModel currentDelivery) async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      await _launchMapsNavigation(currentDelivery);
    } else if (status.isDenied) {
      final result = await Permission.location.request();
      if (result.isGranted) {
        await _launchMapsNavigation(currentDelivery);
      } else {
        _showPermissionDeniedDialog();
      }
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _launchMapsNavigation(DeliveryOrderModel currentDelivery) async {
    try {
      final address = currentDelivery.deliveryAddress['address'];
      if (address == null) {
        throw 'Delivery address is missing';
      }

      final lat = address['location']?.latitude;
      final lng = address['location']?.longitude;

      if (lat == null || lng == null) {
        throw 'Latitude or longitude is missing';
      }

      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        throw 'Could not launch maps';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching navigation: $e')),
      );
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
            'This app needs location permission to navigate to the delivery address. Please grant permission in the app settings.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Open Settings'),
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  void _acceptOrder(DeliveryOrderModel order) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<DeliveryOrderBloc>()
          .add(AcceptOrder(order.id, authState.user.uid));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You need to be logged in to accept orders')),
      );
    }
  }
}
