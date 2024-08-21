import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/delivery/blocs/delivery_order/delivery_order_bloc.dart';
import 'package:eldcare/delivery/presentation/model/delivery_order_model.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

class DeliveryPersonnelHomeContent extends StatefulWidget {
  const DeliveryPersonnelHomeContent({super.key});

  @override
  DeliveryPersonnelHomeContentState createState() =>
      DeliveryPersonnelHomeContentState();
}

class DeliveryPersonnelHomeContentState
    extends State<DeliveryPersonnelHomeContent> {
  @override
  void initState() {
    super.initState();
    _fetchLocationAndOrders();
  }

  Future<void> _fetchLocationAndOrders() async {
    try {
      Position position = await _determinePosition();
      print(
          'Fetched location: ${position.latitude}, ${position.longitude}'); // Debug print
      context.read<DeliveryOrderBloc>().add(FetchAvailableOrders(
            GeoPoint(position.latitude, position.longitude),
            10.0, // Maximum distance in km
          ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location: $e')),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, open settings
      await Geolocator.openLocationSettings();
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, try to request again
        await openAppSettings();
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      await openAppSettings();
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildTopSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text('Today\'s Earnings', style: AppFonts.headline3),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text('\$75.00',
                  style: AppFonts.headline1.copyWith(color: kPrimaryColor)),
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
    return Column(
      children: [
        const Text("Today's Summary", style: AppFonts.headline3),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryCard('Deliveries', '5', Icons.local_shipping),
            _buildSummaryCard('Completed', '3', Icons.check_circle),
            _buildSummaryCard('Pending', '2', Icons.pending_actions),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      color: kWhiteColor,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(icon, size: 30, color: kPrimaryColor),
            const SizedBox(height: 10),
            Text(title, style: AppFonts.bodyText2),
            Text(value, style: AppFonts.headline4),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentDeliverySection() {
    return Column(
      children: [
        const Text("Current Delivery", style: AppFonts.headline3),
        const SizedBox(height: 20),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Order #12345', style: AppFonts.headline4),
                const SizedBox(height: 10),
                const Text('123 Main St, City, State',
                    style: AppFonts.bodyText1),
                const SizedBox(height: 10),
                const Text('2 items', style: AppFonts.bodyText2),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.navigation, color: kWhiteColor),
                      label: const Text('Navigate',
                          style: TextStyle(color: kWhiteColor)),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, color: kWhiteColor),
                      label: const Text('Mark Delivered',
                          style: TextStyle(color: kWhiteColor)),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableOrdersSection() {
    return Column(
      children: [
        const Text("Available Orders", style: AppFonts.headline3),
        const SizedBox(height: 20),
        BlocBuilder<DeliveryOrderBloc, DeliveryOrderState>(
          builder: (context, state) {
            print('Current DeliveryOrderState: $state'); // Debug print
            if (state is DeliveryOrderLoading) {
              return const CircularProgressIndicator();
            } else if (state is DeliveryOrderLoaded) {
              print('Number of orders: ${state.orders.length}'); // Debug print
              if (state.orders.isEmpty) {
                return const Text('No orders available',
                    style: AppFonts.bodyText1);
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.orders.length,
                itemBuilder: (context, index) =>
                    _buildOrderItem(state.orders[index]),
              );
            } else if (state is DeliveryOrderError) {
              return Text('Error: ${state.message}', style: AppFonts.bodyText1);
            }
            return const Text('No orders available', style: AppFonts.bodyText1);
          },
        ),
      ],
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
                    context
                        .read<DeliveryOrderBloc>()
                        .add(AcceptOrder(order.id, 'delivery_boy_id'));
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
