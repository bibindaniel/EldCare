import 'package:eldcare/elduser/blocs/shopmedicines/shop_medicines_bloc.dart';
import 'package:eldcare/elduser/models/shop_medicine.dart';
import 'package:eldcare/elduser/repository/order_repo.dart';
import 'package:eldcare/elduser/repository/shop_medicine_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';

class ShopMedicinesScreen extends StatelessWidget {
  final String shopId;
  final String shopName;

  const ShopMedicinesScreen({
    super.key,
    required this.shopId,
    required this.shopName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ShopMedicineRepository>(
          create: (context) => ShopMedicineRepository(),
        ),
        RepositoryProvider<OrderRepository>(
          create: (context) => OrderRepository(),
        ),
      ],
      child: BlocProvider(
        create: (context) => ShopMedicinesBloc(
          shopMedicineRepository: context.read<ShopMedicineRepository>(),
          orderRepository: context.read<OrderRepository>(),
        )..add(LoadShopMedicines(shopId)),
        child: ShopMedicinesView(shopName: shopName, shopId: shopId),
      ),
    );
  }
}

class ShopMedicinesView extends StatefulWidget {
  final String shopName;
  final String shopId;

  const ShopMedicinesView(
      {super.key, required this.shopName, required this.shopId});

  @override
  ShopMedicinesViewState createState() => ShopMedicinesViewState();
}

class ShopMedicinesViewState extends State<ShopMedicinesView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.shopName} Medicines', style: AppFonts.headline3),
        backgroundColor: kPrimaryColor,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _buildMedicineList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search medicines...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onChanged: (value) {
          context
              .read<ShopMedicinesBloc>()
              .add(SearchShopMedicines(value, widget.shopId));
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return BlocBuilder<ShopMedicinesBloc, ShopMedicinesState>(
      builder: (context, state) {
        Set<String> categories = {
          'All',
          ...state.shopMedicines.map((m) => m.category)
        };
        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              String category = categories.elementAt(index);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMedicineList() {
    return BlocBuilder<ShopMedicinesBloc, ShopMedicinesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        } else if (state.shopMedicines.isEmpty) {
          return const Center(child: Text('No medicines available'));
        } else {
          List<ShopMedicine> filteredMedicines =
              state.shopMedicines.where((medicine) {
            final categoryMatches = _selectedCategory == 'All' ||
                medicine.category == _selectedCategory;
            final searchMatches = medicine.medicineName
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
            return categoryMatches && searchMatches;
          }).toList();

          if (filteredMedicines.isEmpty) {
            return const Center(
                child: Text('No medicines available in this category'));
          }

          return ListView.builder(
            itemCount: filteredMedicines.length,
            itemBuilder: (context, index) {
              final medicine = filteredMedicines[index];
              return _buildMedicineCard(medicine);
            },
          );
        }
      },
    );
  }

  Widget _buildMedicineCard(ShopMedicine medicine) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(medicine.medicineName, style: AppFonts.bodyText1Dark),
            const SizedBox(height: 4),
            Text(medicine.category, style: AppFonts.bodyText2),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\RS ${medicine.price.toStringAsFixed(2)}',
                    style: AppFonts.bodyText1Dark),
                ElevatedButton(
                  onPressed: () {
                    context.read<ShopMedicinesBloc>().add(AddToCart(medicine));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('${medicine.medicineName} added to cart')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Add to Cart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
