import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/elduser/models/order.dart';
import 'package:lottie/lottie.dart';

class OrderDetailsScreen extends StatelessWidget {
  final MedicineOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details', style: AppFonts.appBarTitle),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Navigate to past orders screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildOrderStatus(),
            _buildOrderTimeline(),
            _buildOrderSummary(),
            _buildTrackOrderButton(),
            _buildBackToHomeButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: kLightPrimaryColor,
              shape: BoxShape.circle,
            ),
            child: Lottie.asset('assets/animations/waiting.json',
                width: 100, height: 100),
          ),
          const SizedBox(height: 16),
          Text('Wait for pick up by driver',
              style: AppFonts.headline4.copyWith(color: kPrimaryColor)),
          const SizedBox(height: 8),
          const Text(
            'When it is taken the driver will be processed immediately',
            style: AppFonts.bodyText2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline() {
    final List<Map<String, dynamic>> stages = [
      {
        'icon': Icons.check_circle_outline,
        'title': 'Order accepted',
        'subtitle': 'Wait for the collection time',
        'isCompleted': true,
      },
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'Preparing pick by driver',
        'subtitle':
            'We started process your orders. The order will be ready accepted by driver soon',
        'isCompleted': false,
      },
      {
        'icon': Icons.delivery_dining_outlined,
        'title': 'Ready to delivery',
        'subtitle': 'Driver send you order',
        'isCompleted': false,
      },
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: stages.map((stage) => _buildTimelineItem(stage)).toList(),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> stage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stage['isCompleted'] ? kSuccessColor : kLightGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(stage['icon'], color: kWhiteColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stage['title'],
                    style: AppFonts.headline6.copyWith(
                        color:
                            stage['isCompleted'] ? kSuccessColor : kTextColor)),
                const SizedBox(height: 4),
                Text(stage['subtitle'], style: AppFonts.bodyText2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary',
                style: AppFonts.headline5.copyWith(color: kPrimaryColor)),
            const Divider(height: 24, thickness: 1),
            _buildSummaryItem('Order ID', '#${order.id}'),
            _buildSummaryItem(
                'Total Amount', '₹${order.totalAmount.toStringAsFixed(2)}'),
            _buildSummaryItem('Status', order.status),
            _buildSummaryItem(
                'Placed on', order.createdAt.toString().split(' ')[0]),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppFonts.bodyText2.copyWith(color: kSecondaryTextColor)),
          Text(value,
              style: AppFonts.bodyText1
                  .copyWith(fontWeight: FontWeight.bold, color: kTextColor)),
        ],
      ),
    );
  }

  Widget _buildTrackOrderButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement order tracking logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 8),
            Text('Track my order',
                style: AppFonts.button.copyWith(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildBackToHomeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kPrimaryColor),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, color: kPrimaryColor),
            const SizedBox(width: 8),
            Text('Back to home',
                style: AppFonts.button
                    .copyWith(color: kPrimaryColor, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
