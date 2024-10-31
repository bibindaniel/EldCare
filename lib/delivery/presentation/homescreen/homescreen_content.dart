import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/delivery/blocs/delivery_order/delivery_order_bloc.dart';
import 'package:eldcare/delivery/model/delivery_order_model.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DeliveryPersonnelHomeContent extends StatefulWidget {
  const DeliveryPersonnelHomeContent({super.key});

  @override
  DeliveryPersonnelHomeContentState createState() =>
      DeliveryPersonnelHomeContentState();
}

class DeliveryPersonnelHomeContentState
    extends State<DeliveryPersonnelHomeContent> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndOrders();
    _fetchCurrentDelivery();
    _fetchDeliverySummary();
    _refreshTimer =
        Timer.periodic(Duration(minutes: 5), (_) => _handleRefresh());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await _fetchLocationAndOrders();
    await _fetchCurrentDelivery();
    await _fetchDeliverySummary();
  }

  Future<void> _fetchLocationAndOrders() async {
    if (!mounted) return; // Add this line

    try {
      Position position = await _determinePosition();
      print('Fetched location: ${position.latitude}, ${position.longitude}');

      if (!mounted) return; // Add this line

      context.read<DeliveryOrderBloc>().add(FetchAvailableOrders(
            deliveryBoyLocation:
                GeoPoint(position.latitude, position.longitude),
            maxDistance: 10.0,
          ));
    } catch (e) {
      print('Error in _fetchLocationAndOrders: $e');

      if (!mounted) return; // Add this line

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location: $e')),
      );
    }
  }

  Future<void> _fetchCurrentDelivery() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<DeliveryOrderBloc>()
          .add(FetchCurrentDelivery(deliveryPersonId: authState.user.uid));
    }
  }

  Future<void> _fetchDeliverySummary() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<DeliveryOrderBloc>()
          .add(FetchDeliverySummary(authState.user.uid));
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
    return BlocListener<DeliveryOrderBloc, DeliveryOrderState>(
      listener: (context, state) {
        if (state is DeliveryCodeVerificationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order marked as delivered successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchCurrentDelivery();
          _fetchDeliverySummary();
        } else if (state is DeliveryCodeVerificationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid verification code. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            color: kPrimaryColor,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildTopSection(),
                const SizedBox(height: 30),
                _buildBottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text('Today\'s Earnings', style: AppFonts.headline4Light),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text('₹75.00',
                  style: AppFonts.headline2.copyWith(color: kPrimaryColor)),
            ),
          ],
        ),
        Lottie.asset('assets/animations/delivery.json',
            width: 150, height: 150),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSummarySection(),
          const SizedBox(height: 20),
          _buildCurrentDeliverySection(),
          const SizedBox(height: 20),
          _buildAvailableOrdersSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return BlocBuilder<DeliveryOrderBloc, DeliveryOrderState>(
      builder: (context, state) {
        if (state is DeliveryOrderLoaded) {
          return Column(
            children: [
              const Text("Today's Summary", style: AppFonts.headline3),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryCard('Deliveries',
                      state.summary['total'].toString(), Icons.local_shipping),
                  _buildSummaryCard(
                      'Completed',
                      state.summary['completed'].toString(),
                      Icons.check_circle),
                  _buildSummaryCard(
                      'Pending',
                      state.summary['pending'].toString(),
                      Icons.pending_actions),
                ],
              ),
            ],
          );
        } else if (state is DeliveryOrderLoading) {
          return const CircularProgressIndicator();
        } else {
          return const Text("Unable to load summary");
        }
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      color: kWhiteColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(icon, size: 30, color: kPrimaryColor),
            const SizedBox(height: 10),
            Text(title, style: AppFonts.bodyText2),
            Text(value,
                style: AppFonts.headline4.copyWith(color: kSecondaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentDeliverySection() {
    return BlocBuilder<DeliveryOrderBloc, DeliveryOrderState>(
      builder: (context, state) {
        if (state is DeliveryOrderLoaded) {
          final currentDelivery = state.currentDelivery;
          if (currentDelivery != null) {
            return Column(
              children: [
                const Text("Current Delivery", style: AppFonts.headline3),
                const SizedBox(height: 20),
                _buildCurrentDeliveryCard(currentDelivery),
              ],
            );
          } else {
            return const Text("No current delivery", style: AppFonts.bodyText1);
          }
        } else if (state is DeliveryOrderLoading) {
          return const CircularProgressIndicator(color: kPrimaryColor);
        } else if (state is DeliveryOrderError) {
          return Text('Error: ${state.message}',
              style: AppFonts.bodyText1.copyWith(color: kErrorColor));
        } else {
          return const SizedBox.shrink();
        }
      },
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

  Widget _buildAvailableOrdersSection() {
    return BlocBuilder<DeliveryOrderBloc, DeliveryOrderState>(
      builder: (context, state) {
        if (state is DeliveryOrderLoaded) {
          if (state.orders.isEmpty) {
            return Text('No orders available',
                style: AppFonts.bodyText1.copyWith(color: kSecondaryTextColor));
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.orders.length,
            itemBuilder: (context, index) =>
                _buildOrderItem(state.orders[index]),
          );
        } else if (state is DeliveryOrderLoading) {
          return const CircularProgressIndicator(color: kPrimaryColor);
        } else if (state is DeliveryOrderError) {
          return Text('Error: ${state.message}',
              style: AppFonts.bodyText1.copyWith(color: kErrorColor));
        }
        return const SizedBox.shrink();
      },
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
                ElevatedButton(
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is Authenticated) {
                      context
                          .read<DeliveryOrderBloc>()
                          .add(AcceptOrder(order.id, authState.user.uid));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'You need to be logged in to accept orders')),
                      );
                    }
                  },
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
}
