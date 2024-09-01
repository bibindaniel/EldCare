import 'package:eldcare/elduser/presentation/order/order_details.dart';
import 'package:eldcare/elduser/repository/order_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/elduser/blocs/order/order_bloc.dart';
import 'package:eldcare/elduser/blocs/order/order_event.dart';
import 'package:eldcare/elduser/blocs/order/order_state.dart';
import 'package:eldcare/elduser/models/order.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatelessWidget {
  final String userId;

  const OrdersScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OrderBloc(OrderRepository())..add(FetchOrders(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders', style: AppFonts.appBarTitle),
          backgroundColor: kPrimaryColor,
          elevation: 0,
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor));
            } else if (state is OrderLoaded) {
              return _buildOrderList(context, state.orders);
            } else if (state is OrderError) {
              return Center(
                  child: Text(state.message, style: AppFonts.bodyText1));
            } else {
              return const Center(
                  child: Text('No orders found', style: AppFonts.bodyText1));
            }
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<MedicineOrder> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(context, order);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, MedicineOrder order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(order: order),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, kLightPrimaryColor.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Order #${order.id}',
                        style: AppFonts.headline6.copyWith(
                          color: kPrimaryColor,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _buildStatusChip(order.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: kSecondaryTextColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Placed: ${_formatDate(order.createdAt)}',
                        style: AppFonts.bodyText2.copyWith(
                          color: kSecondaryTextColor,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:',
                        style: AppFonts.bodyText2.copyWith(fontSize: 12)),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: AppFonts.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: kAccentColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        size: 14, color: kSecondaryTextColor),
                    const SizedBox(width: 4),
                    Text(
                      '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                      style: AppFonts.bodyText2.copyWith(
                        color: kSecondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsScreen(order: order),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(60, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'View Details',
                        style: AppFonts.button.copyWith(
                          color: kPrimaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData iconData;
    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange;
        iconData = Icons.hourglass_empty;
        break;
      case 'processing':
        chipColor = Colors.blue;
        iconData = Icons.sync;
        break;
      case 'shipped':
        chipColor = Colors.green;
        iconData = Icons.local_shipping;
        break;
      case 'delivered':
        chipColor = Colors.green.shade800;
        iconData = Icons.check_circle;
        break;
      default:
        chipColor = Colors.grey;
        iconData = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: chipColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
                color: chipColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}
