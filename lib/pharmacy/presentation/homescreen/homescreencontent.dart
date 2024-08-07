import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/pharmacy/blocs/shop/shop_bloc.dart';
import 'package:eldcare/pharmacy/presentation/shop/widgets/shopcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class PharmacistHomeContent extends StatelessWidget {
  const PharmacistHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: kPrimaryColor,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTopSection(),
            const SizedBox(height: 30),
            _buildBottomSection(),
          ],
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
            const Text('Manage Shops', style: AppFonts.headline3),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: kPrimaryColor,
                backgroundColor: kWhiteColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                // Add your button action here
              },
              child: const Text('Add', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        Lottie.asset('assets/animations/pharmacy2.json',
            width: 150, height: 100),
      ],
    );
  }

  Widget _buildBottomSection() {
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
          const SizedBox(height: 12),
          _buildRecentOrdersSection(),
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
          final shops = state.shops;
          if (shops.isEmpty) {
            return const Center(child: Text('No shops available.'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Your Shops", style: AppFonts.headline3Dark),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: shops.length,
                  itemBuilder: (context, index) {
                    final shop = shops[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ShopCard(shop: shop),
                    );
                  },
                ),
              ),
            ],
          );
        } else if (state is ShopErrorState) {
          return Center(child: Text('Error: ${state.error}'));
        } else {
          return const Center(child: Text('No shops available.'));
        }
      },
    );
  }

  Widget _buildRecentOrdersSection() {
    return Column(
      children: [
        const Text("Recent Orders", style: AppFonts.headline3Dark),
        const SizedBox(height: 10),
        Card(
          color: kPrimaryColor,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderItem('Order #1001', 'Pending'),
                const SizedBox(height: 10),
                _buildOrderItem('Order #1002', 'Completed'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(String orderNumber, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(orderNumber, style: AppFonts.bodyText1),
        Chip(
          label: Text(status),
          backgroundColor: status == 'Pending' ? Colors.orange : Colors.green,
          labelStyle: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
