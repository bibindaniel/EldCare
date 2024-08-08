import 'package:eldcare/pharmacy/model/inventory_item.dart';
import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';

class InventoryManagementPage extends StatelessWidget {
  final Shop shop;

  const InventoryManagementPage({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder. You'll need to implement actual inventory fetching logic.
    List<InventoryItem> inventoryItems = [
      InventoryItem(id: '1', name: 'Paracetamol', quantity: 100, price: 5.99),
      InventoryItem(id: '2', name: 'Ibuprofen', quantity: 50, price: 7.99),
      // Add more items as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${shop.name} Inventory', style: AppFonts.headline3),
        backgroundColor: kPrimaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: inventoryItems.length,
              itemBuilder: (context, index) {
                final item = inventoryItems[index];
                return ListTile(
                  title: Text(item.name, style: AppFonts.bodyText1),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: Text('\$${item.price.toStringAsFixed(2)}'),
                  onTap: () {
                    // Implement edit item functionality
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add new item functionality
        },
        backgroundColor: kThridColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
