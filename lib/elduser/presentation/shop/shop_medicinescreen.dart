import 'dart:async';
import 'package:eldcare/elduser/blocs/shopmedicines/shop_medicines_bloc.dart';
import 'package:eldcare/elduser/models/shop_medicine.dart';
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
    return ShopMedicinesView(shopName: shopName, shopId: shopId);
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
  Timer? _debounce;
  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShopMedicinesBloc, ShopMedicinesState>(
      listener: (context, state) {},
      child: BlocBuilder<ShopMedicinesBloc, ShopMedicinesState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close, color: kWhiteColor),
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
              ),
              title: Text(widget.shopName, style: AppFonts.headline3),
              backgroundColor: kPrimaryColor,
              actions: [
                IconButton(
                  icon: Badge(
                    label: Text(state.cart.length.toString()),
                    child: const Icon(
                      Icons.shopping_cart,
                      color: kWhiteColor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                ),
              ],
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
        },
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
        onChanged: _onSearchChanged,
      ),
    );
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context
          .read<ShopMedicinesBloc>()
          .add(SearchShopMedicines(query, widget.shopId));
    });
  }

  Widget _buildCategoryFilter() {
    return BlocBuilder<ShopMedicinesBloc, ShopMedicinesState>(
      builder: (context, state) {
        Set<String> categories = {
          'All',
          ...state.shopMedicines
              .map((m) => m.category ?? 'Uncategorized')
              .where((c) => c.isNotEmpty)
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
                    ?.toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ??
                false;
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
            Text(medicine.medicineName ?? 'Unknown Medicine',
                style: AppFonts.headline1),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(medicine.category ?? 'Uncategorized',
                      style: AppFonts.bodyText2),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.event, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Expires: ${_formatDate(medicine.expiryDate)}',
                  style: AppFonts.bodyText2,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹ ${medicine.price.toStringAsFixed(2)}',
                  style: AppFonts.bodyText1Dark.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showAddToCartDialog(context, medicine);
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

  // Add this method to your ShopMedicinesViewState class
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showAddToCartDialog(BuildContext context, ShopMedicine medicine) {
    int quantity = 1;
    final blocContext = context;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: Text('Add ${medicine.medicineName} to Cart'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                      ),
                      Text(quantity.toString()),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() => quantity++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  child: const Text('Add to Cart'),
                  onPressed: () {
                    // Use the captured context to access the bloc
                    blocContext
                        .read<ShopMedicinesBloc>()
                        .add(AddToCart(medicine, quantity));
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(blocContext).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${medicine.medicineName ?? 'Medicine'} added to cart'),
                        backgroundColor: kSuccessColor,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
