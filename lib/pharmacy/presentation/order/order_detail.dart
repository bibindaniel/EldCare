import 'package:eldcare/pharmacy/model/pharmacist_order.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_event.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderDetailsScreen extends StatelessWidget {
  final PharmacistOrderModel order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}', style: AppFonts.appBarTitle),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderDetails(),
              const SizedBox(height: 24),
              _buildOrderTimeline(),
              const SizedBox(height: 24),
              _buildStatusUpdateSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Details', style: AppFonts.headline4),
            const SizedBox(height: 16),
            _buildDetailRow(
                'Total', '₹${order.totalAmount.toStringAsFixed(2)}'),
            _buildDetailRow('Date', order.formattedDate),
            const SizedBox(height: 16),
            const Text('Items:', style: AppFonts.headline6),
            const SizedBox(height: 8),
            ...order.items.map((item) => _buildItemRow(item)),
            if (order.deliveryAddress != null) ...[
              const SizedBox(height: 16),
              Text('Delivery Address:', style: AppFonts.headline6),
              Text(order.deliveryAddress!, style: AppFonts.bodyText2),
            ],
            if (order.deliveryInstructions != null) ...[
              const SizedBox(height: 16),
              Text('Delivery Instructions:', style: AppFonts.headline6),
              Text(order.deliveryInstructions!, style: AppFonts.bodyText2),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppFonts.bodyText1),
          Text(value, style: AppFonts.bodyText1Colored),
        ],
      ),
    );
  }

  Widget _buildItemRow(PharmacistOrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
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
            '₹${item.price.toStringAsFixed(2)}',
            style: AppFonts.bodyText2Colored,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline() {
    final allStatuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.readyForPickup,
      OrderStatus.assignedToDelivery,
      OrderStatus.inTransit,
      OrderStatus.completed,
    ];
    final currentStatusIndex = allStatuses.indexOf(order.status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Status', style: AppFonts.headline4),
            const SizedBox(height: 16),
            ...List.generate(allStatuses.length, (index) {
              final status = allStatuses[index];
              final isCompleted = index <= currentStatusIndex;
              final isLast = index == allStatuses.length - 1;

              return TimelineTile(
                alignment: TimelineAlign.start,
                isFirst: index == 0,
                isLast: isLast,
                indicatorStyle: IndicatorStyle(
                  width: 24,
                  color: isCompleted ? _getStatusColor(status) : kNeutralColor,
                  iconStyle: IconStyle(
                    color: Colors.white,
                    iconData: isCompleted ? Icons.check : Icons.circle,
                  ),
                ),
                endChild: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    status.toString().split('.').last,
                    style: (isCompleted
                            ? AppFonts.bodyText1Colored
                            : AppFonts.bodyText1)
                        .copyWith(
                            color: isCompleted
                                ? _getStatusColor(status)
                                : kSecondaryTextColor),
                  ),
                ),
                beforeLineStyle: LineStyle(
                  color: isCompleted ? _getStatusColor(status) : kNeutralColor,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdateSection(BuildContext context) {
    final nextStatus = _getNextStatus(order.status);
    if (nextStatus == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Status', style: AppFonts.headline4),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _updateOrderStatus(context, nextStatus),
              child: Text('Mark as ${nextStatus.toString().split('.').last}',
                  style: AppFonts.button),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getStatusColor(nextStatus),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateOrderStatus(BuildContext context, OrderStatus newStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Status Update', style: AppFonts.headline4),
          content: Text(
            'Are you sure you want to update the status to ${newStatus.toString().split('.').last}?',
            style: AppFonts.bodyText1,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: AppFonts.button.copyWith(color: kSecondaryTextColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Update', style: AppFonts.button),
              onPressed: () {
                context
                    .read<PharmacistOrderBloc>()
                    .add(UpdatePharmacistOrderStatus(order.id, newStatus));
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to the order list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  OrderStatus? _getNextStatus(OrderStatus currentStatus) {
    final statuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.readyForPickup,
      OrderStatus.assignedToDelivery,
      OrderStatus.inTransit,
      OrderStatus.completed,
    ];
    final currentIndex = statuses.indexOf(currentStatus);
    if (currentIndex < statuses.length - 1) {
      return statuses[currentIndex + 1];
    }
    return null;
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return kWarningColor;
      case OrderStatus.confirmed:
        return kInfoColor;
      case OrderStatus.readyForPickup:
        return kSuccessColor;
      case OrderStatus.assignedToDelivery:
        return kAccentColor;
      case OrderStatus.inTransit:
        return kTertiaryColor;
      case OrderStatus.completed:
        return kPrimaryColor;
      case OrderStatus.cancelled:
        return kErrorColor;
      default:
        return kSecondaryTextColor;
    }
  }
}
