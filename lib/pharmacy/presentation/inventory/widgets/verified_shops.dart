import 'package:eldcare/pharmacy/presentation/inventory/inventory_management.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';

class VerifiedShopCard extends StatelessWidget {
  final Shop shop;

  const VerifiedShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => InventoryManagementPage(shop: shop)),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: kThridColor,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center the content
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.store,
                    size: 40,
                    color: kWhiteColor,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      shop.name,
                      style: AppFonts.cardTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildContactInfo(),
              const SizedBox(height: 10),
              // _buildStatusChip(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          shop.email,
          style: AppFonts.bodyText1.copyWith(color: kWhiteColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          shop.phoneNumber,
          style: AppFonts.bodyText1.copyWith(color: kWhiteColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: shop.isVerified
            ? kPrimaryColor.withOpacity(0.2)
            : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Verification Status',
            style: TextStyle(
              color: shop.isVerified ? kPrimaryColor : Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            shop.isVerified ? 'Verified' : 'Pending',
            style: TextStyle(
              color: shop.isVerified ? kPrimaryColor : Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
