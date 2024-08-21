import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/pharmacy/model/pharmacist_order.dart';
import 'package:eldcare/pharmacy/repository/pharmacistorderrepositry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_event.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_state.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/pharmacy/blocs/shop/shop_bloc.dart';
import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:timeline_tile/timeline_tile.dart';

class PharmacistOrdersScreen extends StatefulWidget {
  const PharmacistOrdersScreen({super.key});

  @override
  PharmacistOrdersScreenState createState() => PharmacistOrdersScreenState();
}

class PharmacistOrdersScreenState extends State<PharmacistOrdersScreen> {
  Shop? _selectedShop;
  late PharmacistOrderBloc _pharmacistOrderBloc;

  @override
  void initState() {
    super.initState();
    _pharmacistOrderBloc = PharmacistOrderBloc(
      pharmacistOrderRepository: PharmacistOrderRepository(),
      orderRepository: PharmacistOrderRepository(),
    );
    _loadShops();
  }

  @override
  void dispose() {
    _pharmacistOrderBloc.close();
    super.dispose();
  }

  void _loadShops() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final userId = authState.user.uid;
      context.read<ShopBloc>().add(LoadShopsEvent(ownerId: userId));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _pharmacistOrderBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders', style: AppFonts.headline3),
          backgroundColor: kPrimaryColor,
          actions: [
            BlocBuilder<ShopBloc, ShopState>(
              builder: (context, state) {
                if (state is ShopsLoadedState) {
                  return _buildShopDropdown(state.shops);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: _selectedShop == null
            ? const Center(child: Text('Please select a shop'))
            : BlocBuilder<PharmacistOrderBloc, PharmacistOrderState>(
                builder: (context, state) {
                  if (state is PharmacistOrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PharmacistOrderLoaded) {
                    return _buildOrderList(state.orders);
                  } else if (state is PharmacistOrderError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(child: Text('No orders available'));
                },
              ),
      ),
    );
  }

  Widget _buildShopDropdown(List<Shop> shops) {
    final verifiedShops = shops.where((shop) => shop.isVerified).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButton<Shop>(
        value: _selectedShop,
        hint: const Text('Select Shop', style: TextStyle(color: Colors.white)),
        onChanged: (Shop? newValue) {
          setState(() {
            _selectedShop = newValue;
          });
          if (newValue != null) {
            _pharmacistOrderBloc.add(LoadPharmacistOrders(newValue.id));
          }
        },
        items: verifiedShops.map<DropdownMenuItem<Shop>>((Shop shop) {
          return DropdownMenuItem<Shop>(
            value: shop,
            child: Text(shop.name),
          );
        }).toList(),
        style: const TextStyle(color: Colors.white),
        dropdownColor: kPrimaryColor,
        underline: Container(
          height: 2,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOrderList(List<PharmacistOrderModel> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders available for this shop'));
    }
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text('Order #${order.id}', style: AppFonts.headline4Dark),
            subtitle: Text(
              'Status: ${order.formattedStatus}',
              style: TextStyle(color: _getStatusColor(order.status)),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderDetails(order),
                    const SizedBox(height: 16),
                    _buildOrderTimeline(order),
                    const SizedBox(height: 16),
                    _buildStatusUpdateSection(order),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderDetails(PharmacistOrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}',
            style: AppFonts.bodyText1Dark),
        Text('Date: ${order.formattedDate}', style: AppFonts.bodyText2),
        const Divider(),
        const Text('Items:', style: AppFonts.bodyText1Dark),
        ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '${item.medicineName} x${item.quantity} - ₹${item.price.toStringAsFixed(2)}',
                style: AppFonts.bodyText2,
              ),
            )),
        if (order.deliveryAddress != null) ...[
          const Divider(),
          const Text('Delivery Address:', style: AppFonts.bodyText1Dark),
          Text(order.deliveryAddress!, style: AppFonts.bodyText2),
        ],
        if (order.deliveryInstructions != null) ...[
          const Divider(),
          const Text('Delivery Instructions:', style: AppFonts.bodyText1Dark),
          Text(order.deliveryInstructions!, style: AppFonts.bodyText2),
        ],
      ],
    );
  }

  Widget _buildOrderTimeline(PharmacistOrderModel order) {
    final allStatuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.readyForPickup
    ];
    final currentStatusIndex = allStatuses.indexOf(order.status);

    return Column(
      children: List.generate(allStatuses.length, (index) {
        final status = allStatuses[index];
        final isCompleted = index <= currentStatusIndex;
        final isLast = index == allStatuses.length - 1;

        return TimelineTile(
          alignment: TimelineAlign.start,
          isFirst: index == 0,
          isLast: isLast,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: isCompleted ? _getStatusColor(status) : Colors.grey,
            iconStyle: IconStyle(
              color: Colors.white,
              iconData: isCompleted ? Icons.check : Icons.circle,
            ),
          ),
          endChild: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              status.toString().split('.').last,
              style: TextStyle(
                color: isCompleted ? _getStatusColor(status) : Colors.grey,
                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          beforeLineStyle: LineStyle(
              color: isCompleted ? _getStatusColor(status) : Colors.grey),
        );
      }),
    );
  }

  Widget _buildStatusUpdateSection(PharmacistOrderModel order) {
    final nextStatus = _getNextStatus(order.status);
    if (nextStatus == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Update Status:', style: AppFonts.bodyText1Dark),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _updateOrderStatus(order, nextStatus),
          child: Text('Mark as ${nextStatus.toString().split('.').last}'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getStatusColor(nextStatus),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  void _updateOrderStatus(PharmacistOrderModel order, OrderStatus newStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Status Update'),
          content: Text(
            'Are you sure you want to update the status to ${newStatus.toString().split('.').last}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                _pharmacistOrderBloc
                    .add(UpdatePharmacistOrderStatus(order.id, newStatus));
                Navigator.of(context).pop();
              },
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
      OrderStatus.readyForPickup
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
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.readyForPickup:
        return Colors.green;
      case OrderStatus.inTransit:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
