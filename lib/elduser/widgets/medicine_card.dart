import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/elduser/models/medicine.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;

  const MedicineCard({super.key, required this.medicine});

  Color _getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      // Add more colors as needed
      default:
        return Colors.grey; // Default color
    }
  }

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
              CircleAvatar(
                radius: 50,
                backgroundColor: kWhiteColor,
                child: Icon(Icons.medication,
                    size: 40, color: _getColor(medicine.color)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: AppFonts.cardTitle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kWhiteColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Dosage: ${medicine.dosage}",
                      style: AppFonts.cardSubtitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kWhiteColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Time: ${DateFormat('HH:mm').format(medicine.scheduleTimes.isNotEmpty ? medicine.scheduleTimes[0] : DateTime.now())}",
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
