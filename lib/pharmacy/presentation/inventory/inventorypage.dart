import 'package:eldcare/pharmacy/presentation/inventory/add_categery.dart';
import 'package:eldcare/pharmacy/presentation/inventory/widgets/verified_shops.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/pharmacy/blocs/shop/shop_bloc.dart';
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
            const Text('Manage Inventory', style: AppFonts.headline3),
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
              child: const Text('Add Item', style: TextStyle(fontSize: 18)),
            ),
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
          _buildCategoryAndMedicineSection(context),
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
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Your Shops", style: AppFonts.headline3Dark),
                ),
                ...shops.map((shop) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: VerifiedShopCard(
                      shop: shop,
                    ),
                  );
                }),
              ],
            ),
          );
        } else if (state is ShopErrorState) {
          return Center(child: Text('Error: ${state.error}'));
        } else {
          return const Center(child: Text('No shops available.'));
        }
      },
    );
  }

  Widget _buildCategoryAndMedicineSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Categories & Medicines',
            style: AppFonts.headline3Dark,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                label: 'Add Category',
                icon: Icons.category,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddCategoryPage()));
                },
              ),
              _buildActionButton(
                context,
                label: 'Add Medicine Name',
                icon: Icons.medical_services,
                onPressed: () {
                  // Action for Add Medicine Name
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: kPrimaryColor),
      label: Text(label, style: const TextStyle(color: kPrimaryColor)),
      style: ElevatedButton.styleFrom(
        backgroundColor: kWhiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
