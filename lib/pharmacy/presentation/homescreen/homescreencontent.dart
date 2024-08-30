import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/pharmacy/blocs/shop/shop_bloc.dart';
import 'package:eldcare/pharmacy/presentation/inventory/inventorypage.dart';
import 'package:eldcare/pharmacy/presentation/order/pharmacist_order_screen.dart';
import 'package:eldcare/pharmacy/presentation/shop/add_shop.dart';
import 'package:eldcare/pharmacy/presentation/shop/widgets/shopcard.dart';
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
              width: 100, height: 100),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Orders", style: AppFonts.headline4),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildOrderItem('Order #1001', 'Pending', kWarningColor),
                  const Divider(height: 24),
                  _buildOrderItem('Order #1002', 'Completed', kSuccessColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String orderNumber, String status, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(orderNumber, style: AppFonts.bodyText1),
        Chip(
          label:
              Text(status, style: AppFonts.button.copyWith(color: statusColor)),
          backgroundColor: statusColor.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ],
    );
  }
}
