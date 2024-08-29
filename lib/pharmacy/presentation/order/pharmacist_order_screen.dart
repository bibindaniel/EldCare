import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/pharmacy/model/pharmacist_order.dart';
import 'package:eldcare/pharmacy/presentation/order/order_detail.dart';
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
          title: Text('Orders', style: AppFonts.headline3Light),
          backgroundColor: kPrimaryColor,
        ),
        body: Column(
          children: [
            _buildShopSelector(),
            Expanded(
              child: _selectedShop == null
                  ? const Center(child: Text('Please select a shop'))
                  : BlocBuilder<PharmacistOrderBloc, PharmacistOrderState>(
                      builder: (context, state) {
                        if (state is PharmacistOrderLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is PharmacistOrderLoaded) {
                          return _buildOrderList(state.orders);
                        } else if (state is PharmacistOrderError) {
                          return Center(child: Text('Error: ${state.message}'));
                        }
                        return const Center(child: Text('No orders available'));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopSelector() {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        if (state is ShopsLoadedState) {
          final verifiedShops =
              state.shops.where((shop) => shop.isVerified).toList();
          return SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: verifiedShops.length,
              itemBuilder: (context, index) {
                final shop = verifiedShops[index];
                final isSelected = _selectedShop?.id == shop.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedShop = shop;
                    });
                    _pharmacistOrderBloc.add(LoadPharmacistOrders(shop.id));
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryColor : kLightPrimaryColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store,
                          color: isSelected ? kWhiteColor : kPrimaryColor,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          shop.name,
                          style: TextStyle(
                            color: isSelected ? kWhiteColor : kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrderList(List<PharmacistOrderModel> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No orders available for this shop',
          style: AppFonts.bodyText1,
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: BlocProvider.of<PharmacistOrderBloc>(context),
                    child: OrderDetailsScreen(order: order),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${order.id}',
                          style: AppFonts.headline5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(order.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Date: ${_formatDate(order.createdAt)}',
                    style:
                        AppFonts.bodyText2.copyWith(color: kSecondaryTextColor),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                        style: AppFonts.bodyText1,
                      ),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(2)}',
                        style:
                            AppFonts.headline5.copyWith(color: kPrimaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildOrderProgress(order.status),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        status.toString().split('.').last,
        style: AppFonts.caption.copyWith(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderProgress(OrderStatus status) {
    const allStatuses = OrderStatus.values;
    final currentIndex = allStatuses.indexOf(status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Progress',
          style: AppFonts.bodyText2.copyWith(color: kSecondaryTextColor),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (currentIndex + 1) / allStatuses.length,
          backgroundColor: kNeutralColor,
          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(status)),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
