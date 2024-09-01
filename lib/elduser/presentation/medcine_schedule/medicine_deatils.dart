import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/elduser/presentation/medcine_schedule/edit_medicine_scheulde.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/elduser/blocs/medicine/medicine_bloc.dart';
import 'package:eldcare/elduser/models/medicine.dart';
import 'package:lottie/lottie.dart';

class MedicineDetailPage extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailPage({super.key, required this.medicine});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicineBloc(),
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Medicine Details',
              style: TextStyle(color: Colors.white)),
        ),
        body: BlocConsumer<MedicineBloc, MedicineState>(
          listener: (context, state) {
            if (state is MedicineSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Medicine removed successfully'),
                  backgroundColor: kSuccessColor,
                ),
              );
              // Navigate back to the previous screen after a short delay
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.of(context).pop();
              });
            } else if (state is MedicineError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.error}'),
                  backgroundColor: kErrorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'View and edit schedule',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          maxLines: 2,
                        ),
                      ),
                      Lottie.asset(
                        'assets/animations/medical.json',
                        width: 60,
                        height: 60,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: kWhiteColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Hero(
                                  tag: 'medicine_image_${medicine.id}',
                                  child: CircleAvatar(
                                    radius: 120,
                                    backgroundColor: _getColor(medicine.color),
                                    child: Image.asset(
                                      _getShapeImagePath(medicine.shape),
                                      color: kWhiteColor,
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoCard(
                                          'Pill Name', medicine.name),
                                      _buildInfoCard(
                                          'Next Dose', _getNextDoseTime()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            _buildElegantInfoCard(_buildDoseInfo()),
                            const SizedBox(height: 20),
                            _buildElegantInfoCard(_buildProgramInfo()),
                            const SizedBox(height: 20),
                            _buildElegantInfoCard(_buildQuantityInfo()),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    title: 'Edit',
                                    icon: Icons.edit,
                                    color: kThridColor,
                                    onPressed: () {
                                      _showEditDialog(context);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildActionButton(
                                    title: 'Remove',
                                    icon: Icons.delete,
                                    color: kSecondaryColor,
                                    onPressed: () {
                                      _showRemoveDialog(context);
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildElegantInfoCard(Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kThridColor)),
        ],
      ),
    );
  }

  Widget _buildDoseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dose', style: AppFonts.cardTitle),
        Text(
          '${medicine.schedules.length} times | ${medicine.schedules.map((s) => '${DateFormat('h:mm a').format(s.time)} - ${s.dosage}').join(', ')}',
          style: AppFonts.cardSubtitle,
        ),
      ],
    );
  }

  Widget _buildProgramInfo() {
    int totalWeeks =
        medicine.endDate.difference(medicine.startDate).inDays ~/ 7;
    int weeksLeft = medicine.endDate.difference(DateTime.now()).inDays ~/ 7;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Program', style: AppFonts.cardTitle),
        Text(
          'Total $totalWeeks weeks | $weeksLeft weeks left',
          style: AppFonts.cardSubtitle,
        ),
      ],
    );
  }

  Widget _buildQuantityInfo() {
    int totalQuantity = medicine.quantity;
    int remainingQuantity = medicine.quantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quantity', style: AppFonts.cardTitle),
        Text('Total $totalQuantity capsules | $remainingQuantity capsules left',
            style: AppFonts.cardSubtitle),
      ],
    );
  }

  String _getNextDoseTime() {
    DateTime now = DateTime.now();
    for (MedicineSchedule schedule in medicine.schedules) {
      if (schedule.time.isAfter(now)) {
        return '${DateFormat('h:mm a').format(schedule.time)} - ${schedule.dosage}';
      }
    }
    return '${DateFormat('h:mm a').format(medicine.schedules.first.time)} - ${medicine.schedules.first.dosage}';
  }

  void _showEditDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMedicinePage(medicine: medicine),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Medicine'),
        content: const Text('Are you sure you want to remove this medicine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.pop(dialogContext);
              // Dispatch the remove event
              context
                  .read<MedicineBloc>()
                  .add(RemoveMedicine(medicineId: medicine.id));
              // Don't pop the context here, let the BlocListener handle navigation
            },
            style: TextButton.styleFrom(foregroundColor: kErrorColor),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

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
}
