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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: kSurfaceColor,
        child: Container(
          width: 160,
          height: 220, // Fixed height to prevent overflow
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store,
                  size: 36,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  shop.name,
                  style: AppFonts.headline6,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              _buildVerificationBadge(),
              const SizedBox(height: 8),
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
            color: kSuccessColor,
            size: 24,
          )
        : const Icon(
            Icons.pending,
            color: kWarningColor,
            size: 24,
          );
  }

  Widget _buildStatusChip() {
    final isVerified = shop.isVerified;
    final backgroundColor = isVerified ? kSuccessColor : kWarningColor;
    final textColor = isVerified ? kSuccessColor : kWarningColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Verification Status',
            style: AppFonts.caption.copyWith(color: textColor),
          ),
          const SizedBox(height: 2),
          Text(
            isVerified ? 'Verified' : 'Pending',
            style: AppFonts.button.copyWith(color: textColor, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
