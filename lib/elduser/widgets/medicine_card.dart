import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:flutter/material.dart';

class MedicineCard extends StatelessWidget {
  const MedicineCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        color: kSecondaryColor,
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(70),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                  radius: 50,
                  backgroundColor: kWhiteColor,
                  child:
                      Icon(Icons.medication, size: 40, color: kPrimaryColor)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "medine name",
                      style: AppFonts.cardTitle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kWhiteColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Dosage: 200 mg",
                      style: AppFonts.cardSubtitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kWhiteColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Time: 8:30",
                      style: AppFonts.cardSubtitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kWhiteColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
