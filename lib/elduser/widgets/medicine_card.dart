import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/elduser/models/medicine.dart';
import 'package:eldcare/elduser/presentation/medcine_schedule/medicine_deatils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;

  const MedicineCard({super.key, required this.medicine});

  Color _getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'white':
        return Colors.black;
      case 'cream':
        return const Color(0xFFFFFDD0);
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'red':
        return Colors.red;
      case 'light blue':
        return Colors.lightBlue;
      case 'dark blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'brown':
        return Colors.brown;
      case 'gray':
        return Colors.grey;
      case 'black':
        return Colors.black;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.black; // Default color
    }
  }

  String _getShapeImagePath(String shape) {
    switch (shape.toLowerCase()) {
      case 'circle':
        return 'assets/images/pills/meds.png';
      case 'rectangle':
        return 'assets/images/pills/round-pill.png';
      case 'triangle':
        return 'assets/images/pills/oval-pill.png';
      case 'square':
        return 'assets/images/pills/inhaler.png';
      case 'oval':
        return 'assets/images/pills/eye-drops.png';
      case 'bottle':
        return 'assets/images/pills/pills-bottle.png';
      default:
        return 'assets/images/pills/meds.png'; // Default shape
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicineDetailPage(medicine: medicine),
          ),
        );
      },
      child: SizedBox(
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
                Hero(
                  tag: 'medicine_image_${medicine.id}',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: kWhiteColor,
                    child: Image.asset(
                      _getShapeImagePath(medicine.shape),
                      color: _getColor(medicine.color),
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'medicine_name_${medicine.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            medicine.name,
                            style: AppFonts.cardTitle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kWhiteColor,
                            ),
                          ),
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
      ),
    );
  }
}
