import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_event.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_state.dart';
import 'package:eldcare/pharmacy/blocs/shop/shop_bloc.dart';
import 'package:eldcare/pharmacy/model/pharmacist_order.dart';
import 'package:eldcare/pharmacy/presentation/inventory/inventorypage.dart';
import 'package:eldcare/pharmacy/presentation/order/pharmacist_order_screen.dart';
import 'package:eldcare/pharmacy/presentation/shop/add_shop.dart';
import 'package:eldcare/pharmacy/presentation/shop/widgets/shopcard.dart';
import 'package:eldcare/pharmacy/repository/pharmacistorderrepositry.dart';
import 'package:eldcare/pharmacy/repository/shop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class PharmacistHomeContent extends StatelessWidget {
  const PharmacistHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildShopsSection(),
          const SizedBox(height: 24),
          _buildRecentOrdersSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Manage Your Pharmacy', style: AppFonts.headline3Light),
              const SizedBox(height: 8),
            ],
          ),
          Lottie.asset('assets/animations/pharmacy2.json',
              width: 80, height: 80),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: AppFonts.headline4),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                context,
                Icons.add_business,
                'Add Shop',
                kSecondaryColor,
                () => _navigateToAddShop(context),
              ),
              _buildActionButton(
                context,
                Icons.inventory_2,
                'Manage Inventory',
                kAccentColor,
                () => _navigateToInventory(context),
              ),
              _buildActionButton(
                context,
                Icons.receipt_long,
                'View Orders',
                kSuccessColor,
                () => _navigateToOrders(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppFonts.bodyText2),
        ],
      ),
    );
  }

  void _navigateToAddShop(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddShopPage(shopRepository: ShopRepository()),
    ));
  }

  void _navigateToInventory(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const InventoryPage(),
    ));
  }

  void _navigateToOrders(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const PharmacistOrdersScreen(),
    ));
  }

  Widget _buildShopsSection() {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        if (state is ShopInitialState || state is ShopLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ShopsLoadedState) {
          final shops = state.shops;
          if (shops.isEmpty) {
            return const Center(
                child: Text('No shops available.', style: AppFonts.bodyText1));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text("Your Shops", style: AppFonts.headline4),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    final shop = shops[index];
                    return Padding(
                      padding:
                          EdgeInsets.only(left: index == 0 ? 24 : 0, right: 16),
                      child: ShopCard(shop: shop),
                    );
                  },
                ),
              ),
            ],
          );
        } else if (state is ShopErrorState) {
          return Center(
              child: Text('Error: ${state.error}', style: AppFonts.bodyText1));
        } else {
          return const Center(
              child: Text('No shops available.', style: AppFonts.bodyText1));
        }
      },
    );
  }

  Widget _buildRecentOrdersSection() {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, shopState) {
        if (shopState is ShopsLoadedState && shopState.shops.isNotEmpty) {
          final shopId = shopState.shops.first.id;

          return BlocProvider<PharmacistOrderBloc>(
            create: (context) {
              final bloc = PharmacistOrderBloc(
                pharmacistOrderRepository: PharmacistOrderRepository(),
              );
              Future.microtask(() => bloc.add(LoadRecentOrders(shopId)));
              return bloc;
            },
            child: BlocBuilder<PharmacistOrderBloc, PharmacistOrderState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long,
                              color: kPrimaryColor, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Recent Orders",
                              style: AppFonts.headline4.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _navigateToOrders(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              'View All',
                              style: AppFonts.button.copyWith(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (state is PharmacistOrderLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (state is PharmacistOrderLoaded &&
                          state.orders.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              children: state.orders.map((order) {
                                return Column(
                                  children: [
                                    _buildOrderItem(
                                      order: order,
                                      statusColor:
                                          _getStatusColor(order.status),
                                    ),
                                    if (order != state.orders.last)
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.grey.withOpacity(0.1),
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      else if (state is PharmacistOrderError)
                        _buildErrorState(state.message)
                      else if (state is PharmacistOrderLoaded)
                        _buildEmptyState()
                      else
                        const SizedBox.shrink(),
                    ],
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

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kErrorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: kErrorColor, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error Loading Orders',
            style: AppFonts.headline4.copyWith(color: kErrorColor),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppFonts.bodyText2
                .copyWith(color: kErrorColor.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/animations/empty_box.json',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 16),
          Text(
            'No Recent Orders',
            style: AppFonts.bodyText2.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'New orders will appear here',
            style: AppFonts.bodyText2.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem({
    required PharmacistOrderModel order,
    required Color statusColor,
  }) {
    return InkWell(
      onTap: () {
        // Handle order tap - navigate to order details
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getOrderStatusIcon(order.status),
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${order.id.substring(0, 6)}',
                          style: AppFonts.headline4.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(2)}',
                        style: AppFonts.headline4.copyWith(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.formattedDate,
                          style: AppFonts.caption.copyWith(
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.formattedStatus,
                          style: AppFonts.caption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getOrderStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending_actions;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.readyForPickup:
        return Icons.shopping_bag;
      case OrderStatus.assignedToDelivery:
        return Icons.delivery_dining;
      case OrderStatus.inTransit:
        return Icons.local_shipping;
      case OrderStatus.completed:
        return Icons.task_alt;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_long;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return kWarningColor;
      case OrderStatus.confirmed:
        return kPrimaryColor;
      case OrderStatus.readyForPickup:
        return kAccentColor;
      case OrderStatus.assignedToDelivery:
        return kSecondaryColor;
      case OrderStatus.inTransit:
        return kInfoColor;
      case OrderStatus.completed:
        return kSuccessColor;
      case OrderStatus.cancelled:
        return kErrorColor;
      default:
        return kWarningColor;
    }
  }
}
