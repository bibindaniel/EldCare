import 'package:eldcare/admin/presentation/adminstyles/adminstyles.dart';
import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:flutter/material.dart';

class ShopDetailPage extends StatelessWidget {
  final Shop shop;

  const ShopDetailPage({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shop.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${shop.name}', style: AdminStyles.bodyStyle),
            Text('Email: ${shop.email}', style: AdminStyles.bodyStyle),
            Text('Phone: ${shop.phoneNumber}', style: AdminStyles.bodyStyle),
            Text('Address: ${shop.address}', style: AdminStyles.bodyStyle),
            Text('License: ${shop.licenseNumber}',
                style: AdminStyles.bodyStyle),
            Text('Verified: ${shop.isVerified ? "Yes" : "No"}',
                style: AdminStyles.bodyStyle),
            // Add other details as needed
          ],
        ),
      ),
    );
  }
}
