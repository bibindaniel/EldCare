import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/pharmacy/model/pharmacist_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_event.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_state.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/pharmacy/blocs/shop/shop_bloc.dart';
import 'package:eldcare/pharmacy/model/shop.dart';

class PharmacistOrdersScreen extends StatefulWidget {
  const PharmacistOrdersScreen({super.key});

  @override
  PharmacistOrdersScreenState createState() => PharmacistOrdersScreenState();
}

class PharmacistOrdersScreenState extends State<PharmacistOrdersScreen> {
  Shop? _selectedShop;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  void _loadShops() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final userId = authState.user.uid;
      context.read<ShopBloc>().add(LoadShopsEvent(ownerId: userId));
    } else {
      // Handle the case when the user is not authenticated
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  Widget _buildShopDropdown(List<Shop> shops) {
    // Filter only verified shops
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
            context
                .read<PharmacistOrderBloc>()
                .add(LoadPharmacistOrders(newValue.id));
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
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Order #${order.id}', style: AppFonts.headline4Dark),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${order.status.toString().split('.').last}'),
                Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}'),
                Text('Date: ${order.createdAt.toString().split(' ')[0]}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showOrderOptions(order),
            ),
            onTap: () => _showOrderDetails(order),
          ),
        );
      },
    );
  }

  void _showOrderOptions(PharmacistOrderModel order) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _showOrderDetails(order);
                },
              ),
              ListTile(
                leading: const Icon(Icons.update),
                title: const Text('Update Status'),
                onTap: () {
                  Navigator.pop(context);
                  _showUpdateStatusDialog(order);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOrderDetails(PharmacistOrderModel order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order #${order.id}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Status: ${order.status.toString().split('.').last}'),
                Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}'),
                Text('Date: ${order.createdAt.toString().split(' ')[0]}'),
                const Divider(),
                const Text('Items:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...order.items.map(
                    (item) => Text('${item.medicineName} x${item.quantity}')),
                if (order.deliveryAddress != null) ...[
                  const Divider(),
                  const Text('Delivery Address:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(order.deliveryAddress!),
                ],
                if (order.deliveryInstructions != null) ...[
                  const Divider(),
                  const Text('Delivery Instructions:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(order.deliveryInstructions!),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateStatusDialog(PharmacistOrderModel order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Order Status'),
          content: DropdownButton<OrderStatus>(
            value: order.status,
            items: OrderStatus.values.map((OrderStatus status) {
              return DropdownMenuItem<OrderStatus>(
                value: status,
                child: Text(status.toString().split('.').last),
              );
            }).toList(),
            onChanged: (OrderStatus? newValue) {
              if (newValue != null) {
                context
                    .read<PharmacistOrderBloc>()
                    .add(UpdatePharmacistOrderStatus(order.id, newValue));
                Navigator.of(context).pop();
              }
            },
          ),
        );
      },
    );
  }
}
