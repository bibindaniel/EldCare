import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:eldcare/pharmacy/presentation/shop/updateshop.dart';
import 'package:eldcare/pharmacy/repository/shop.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;

  const ShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateShopPage(
              shop: shop,
              shopRepository: ShopRepository(),
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: kThridColor,
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store,
                    size: 40,
                    color: kWhiteColor,
                  ),
                  SizedBox(width: 8)
                ],
              ),
              const SizedBox(height: 12),
              Text(
                shop.name,
                style: AppFonts.subtitle1Bold.copyWith(
                  color: kWhiteColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              _buildVerificationBadge(),
              const SizedBox(
                height: 10,
              ),
              _buildStatusChip(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationBadge() {
    return shop.isVerified
        ? const Icon(
            Icons.verified,
            color: kPrimaryColor,
            size: 24,
          )
        : const Icon(
            Icons.pending,
            color: Colors.orange,
            size: 24,
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
