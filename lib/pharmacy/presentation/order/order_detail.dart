import 'dart:convert';

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

  const OrderDetailsScreen({super.key, required this.order});

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
              const Text('Delivery Address:', style: AppFonts.headline6),
              const SizedBox(height: 8),
              _buildDeliveryAddress(order.deliveryAddress!),
            ],
            const SizedBox(height: 16),
            _buildPrescriptionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddress(String addressString) {
    try {
      // Parse the string into a Map
      final deliveryAddress = json.decode(addressString.replaceAll("'", '"'))
          as Map<String, dynamic>;
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
          Row(
            children: [
              const Icon(Icons.label_outline, size: 16, color: kPrimaryColor),
              const SizedBox(width: 4),
              Text('Label: ${deliveryAddress['label'] ?? ''}',
                  style: AppFonts.bodyText2Colored
                      .copyWith(fontStyle: FontStyle.italic)),
            ],
          ),
          if (deliveryAddress['isDefault'] == true) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 16, color: kSuccessColor),
                const SizedBox(width: 4),
                Text('Default Address',
                    style: AppFonts.bodyText2.copyWith(color: kSuccessColor)),
              ],
            ),
          ],
        ],
      );
    } catch (e) {
      // If parsing fails, display the raw string
      return Text('Address: $addressString', style: AppFonts.bodyText2);
    }
  }

  Widget _buildPrescriptionButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Implement prescription viewing functionality
        print('View prescription');
      },
      icon: const Icon(Icons.description),
      label: const Text('View Prescription'),
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    final canCancel = _canCancelOrder(order.status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Actions', style: AppFonts.headline4),
            const SizedBox(height: 16),
            if (nextStatus != null)
              ElevatedButton(
                onPressed: () => _updateOrderStatus(context, nextStatus),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getStatusColor(nextStatus),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Mark as ${nextStatus.toString().split('.').last}',
                    style: AppFonts.button),
              ),
            if (canCancel) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _cancelOrder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kErrorColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Cancel Order', style: AppFonts.button),
              ),
            ],
            if (nextStatus == null && !canCancel) ...[
              const SizedBox(height: 12),
              Text(
                _getNoActionMessage(order.status),
                style: AppFonts.bodyText1.copyWith(color: kSecondaryTextColor),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getNoActionMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.readyForPickup:
        return 'Order is ready for pickup. Waiting for delivery assignment.';
      case OrderStatus.assignedToDelivery:
        return 'Order has been assigned to a delivery person.';
      case OrderStatus.inTransit:
        return 'Order is in transit. No further actions required.';
      case OrderStatus.completed:
        return 'Order has been completed. No further actions available.';
      case OrderStatus.cancelled:
        return 'Order has been cancelled. No further actions available.';
      default:
        return 'No actions available for the current order status.';
    }
  }

  OrderStatus? _getNextStatus(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.pending:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.readyForPickup;
      default:
        return null;
    }
  }

  bool _canCancelOrder(OrderStatus currentStatus) {
    return currentStatus != OrderStatus.inTransit &&
        currentStatus != OrderStatus.completed &&
        currentStatus != OrderStatus.cancelled;
  }

  void _updateOrderStatus(BuildContext context, OrderStatus newStatus) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: Text('Update', style: AppFonts.button),
              onPressed: () {
                BlocProvider.of<PharmacistOrderBloc>(context)
                    .add(UpdatePharmacistOrderStatus(order.id, newStatus));
                Navigator.of(dialogContext).pop();
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

  void _cancelOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm Cancellation', style: AppFonts.headline4),
          content: Text(
            'Are you sure you want to cancel this order?',
            style: AppFonts.bodyText1,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No',
                  style: AppFonts.button.copyWith(color: kSecondaryTextColor)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: Text('Yes', style: AppFonts.button),
              onPressed: () {
                BlocProvider.of<PharmacistOrderBloc>(context).add(
                    UpdatePharmacistOrderStatus(
                        order.id, OrderStatus.cancelled));
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop(); // Return to the order list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kErrorColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
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
