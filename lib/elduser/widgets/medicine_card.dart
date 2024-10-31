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

  String _getDosageDisplay() {
    MedicineSchedule? nextSchedule = _getNextSchedule();
    return nextSchedule?.dosage ?? 'No upcoming dose';
  }

  String _getNextDoseTime() {
    MedicineSchedule? nextSchedule = _getNextSchedule();
    return nextSchedule != null
        ? DateFormat('HH:mm').format(nextSchedule.time)
        : 'No upcoming dose';
  }

  MedicineSchedule? _getNextSchedule() {
    if (medicine.schedules.isEmpty) {
      return null;
    }

    DateTime now = DateTime.now();
    for (MedicineSchedule schedule in medicine.schedules) {
      if (schedule.time.isAfter(now)) {
        return schedule;
      }
    }

    // If all schedules are in the past, return a new schedule for the next day
    DateTime nextDay = DateTime(
      now.year,
      now.month,
      now.day + 1,
      medicine.schedules.first.time.hour,
      medicine.schedules.first.time.minute,
    );
    return MedicineSchedule(
      time: nextDay,
      dosage: medicine.schedules.first.dosage,
    );
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
                        "Dosage: ${_getDosageDisplay()}",
                        style: AppFonts.cardSubtitle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kWhiteColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Next dose: ${_getNextDoseTime()}",
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
