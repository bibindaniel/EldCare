import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/pharmacy/blocs/shop/shop_bloc.dart';
import 'package:eldcare/pharmacy/presentation/inventory/inventory_management.dart';
import 'package:lottie/lottie.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: kPrimaryColor,
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTopSection(),
              const SizedBox(height: 30),
              _buildBottomSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text('Manage Inventory', style: AppFonts.headline3Light),
            const SizedBox(height: 20),
          ],
        ),
        Lottie.asset('assets/animations/pharmacy2.json',
            width: 150, height: 100),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildShopsSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildShopsSection() {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        if (state is ShopInitialState || state is ShopLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ShopsLoadedState) {
          final shops = state.shops.where((shop) => shop.isVerified).toList();
          if (shops.isEmpty) {
            return const Center(child: Text('No shops available.'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Your Shops", style: AppFonts.headline3),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shops.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) =>
                    _buildShopCard(context, shops[index]),
              ),
            ],
          );
        } else {
          return const Center(child: Text('Error loading shops.'));
        }
      },
    );
  }

  Widget _buildShopCard(BuildContext context, Shop shop) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InventoryManagementPage(shop: shop),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store, color: kPrimaryColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shop.name, style: AppFonts.headline4),
                    const SizedBox(height: 4),
                    Text(shop.address, style: AppFonts.bodyText2),
                    const SizedBox(height: 8),
                    Text('Tap to manage inventory',
                        style: AppFonts.caption.copyWith(color: kPrimaryColor)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kPrimaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
