import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/elduser/models/order.dart';
import 'package:lottie/lottie.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderDetailsScreen extends StatelessWidget {
  final MedicineOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}', style: AppFonts.appBarTitle),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildOrderStatus(),
            _buildOrderTimeline(),
            _buildOrderSummary(),
            _buildOrderItems(),
            // _buildDeliveryAddress(),
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
            child: Lottie.asset(_getStatusAnimation(), width: 100, height: 100),
          ),
          const SizedBox(height: 16),
          Text(_getStatusTitle(),
              style: AppFonts.headline4.copyWith(color: kPrimaryColor)),
          const SizedBox(height: 8),
          Text(
            _getStatusDescription(),
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
        'title': 'Order Placed',
        'isCompleted': true,
      },
      {
        'icon': Icons.local_pharmacy_outlined,
        'title': 'Confirmed by Pharmacy',
        'isCompleted': [
          'readyForPickup',
          'assignedToDelivery',
          'inTransit',
          'completed'
        ].contains(order.status),
      },
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'Out for Delivery',
        'isCompleted': ['inTransit', 'completed'].contains(order.status),
      },
      {
        'icon': Icons.done_all,
        'title': 'Delivered',
        'isCompleted': order.status == 'completed',
      },
    ];

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Timeline', style: AppFonts.headline5),
            const SizedBox(height: 16),
            ...List.generate(stages.length, (index) {
              final stage = stages[index];
              final isLast = index == stages.length - 1;

              return TimelineTile(
                alignment: TimelineAlign.start,
                isFirst: index == 0,
                isLast: isLast,
                indicatorStyle: IndicatorStyle(
                  width: 24,
                  color: stage['isCompleted'] ? kSuccessColor : kNeutralColor,
                  iconStyle: IconStyle(
                    color: Colors.white,
                    iconData: stage['isCompleted'] ? Icons.check : Icons.circle,
                  ),
                ),
                endChild: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    stage['title'],
                    style: (stage['isCompleted']
                            ? AppFonts.bodyText1Colored
                            : AppFonts.bodyText1)
                        .copyWith(
                            color: stage['isCompleted']
                                ? kSuccessColor
                                : kSecondaryTextColor),
                  ),
                ),
                beforeLineStyle: LineStyle(
                  color: stage['isCompleted'] ? kSuccessColor : kNeutralColor,
                ),
              );
            }),
          ],
        ),
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
            _buildSummaryItem('Status', _getStatusTitle()),
            _buildSummaryItem('Placed on', _formatDate(order.createdAt)),
            _buildSummaryItem('Payment ID', order.paymentId),
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

  Widget _buildOrderItems() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Items',
                style: AppFonts.headline5.copyWith(color: kPrimaryColor)),
            const Divider(height: 24, thickness: 1),
            ...order.items.map((item) => _buildOrderItemRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.medicineName} x${item.quantity}',
              style: AppFonts.bodyText2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '₹${(item.price * item.quantity).toStringAsFixed(2)}',
            style: AppFonts.bodyText2Colored,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery Address',
                style: AppFonts.headline5.copyWith(color: kPrimaryColor)),
            const Divider(height: 24, thickness: 1),
            Text(order.deliveryAddress.toString(), style: AppFonts.bodyText2),
            const SizedBox(height: 8),
            Text('Phone: ${order.phoneNumber}', style: AppFonts.bodyText2),
          ],
        ),
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

  String _getStatusAnimation() {
    switch (order.status) {
      case 'pending':
        return 'assets/animations/pending.json';
      case 'confirmed':
        return 'assets/animations/waiting.json';
      case 'readyForPickup':
      case 'assignedToDelivery':
        return 'assets/animations/waiting.json';
      case 'inTransit':
        return 'assets/animations/delivery.json';
      case 'completed':
        return 'assets/animations/completed.json';
      case 'cancelled':
        return 'assets/animations/cancelled.json';
      default:
        return 'assets/animations/waiting.json';
    }
  }

  String _getStatusTitle() {
    switch (order.status) {
      case 'pending':
        return 'Order Placed';
      case 'confirmed':
        return 'Order Confirmed';
      case 'readyForPickup':
        return 'Ready for Pickup';
      case 'assignedToDelivery':
      case 'inTransit':
        return 'Out for Delivery';
      case 'completed':
        return 'Order Delivered';
      case 'cancelled':
        return 'Order Cancelled';
      default:
        return 'Processing Order';
    }
  }

  String _getStatusDescription() {
    switch (order.status) {
      case 'pending':
        return 'Your order has been placed and is awaiting confirmation from the pharmacy.';
      case 'confirmed':
        return 'The pharmacy has confirmed your order and is preparing it.';
      case 'readyForPickup':
        return 'Your order is ready and waiting for a delivery person to pick it up.';
      case 'assignedToDelivery':
        return 'A delivery person has been assigned to your order.';
      case 'inTransit':
        return 'Your order is on its way to you.';
      case 'completed':
        return 'Your order has been delivered. Enjoy!';
      case 'cancelled':
        return 'We\'re sorry, but your order has been cancelled.';
      default:
        return 'We\'re processing your order. Please wait for updates.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
