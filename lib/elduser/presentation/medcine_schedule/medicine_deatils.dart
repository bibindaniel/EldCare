import 'package:eldcare/core/theme/font.dart';
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
                  content: Text('Operation Completed successfully'),
                  backgroundColor: kSuccessColor,
                ),
              );
              Navigator.pop(context);
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
                                          'Pill Dosage', medicine.dosage),
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
                                    color: Colors.blue,
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
                                    color: Colors.red,
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
        color: Colors.white,
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

  // @override
  // Widget build(BuildContext context) {
  //   return BlocProvider(
  //     create: (context) => MedicineBloc(),
  //     child: BlocConsumer<MedicineBloc, MedicineState>(
  //       listener: (context, state) {
  //         if (state is MedicineSuccess) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //                 content: Text('Operation completed successfully'),
  //                 backgroundColor: kSuccessColor),
  //           );
  //           Navigator.pop(context);
  //         } else if (state is MedicineError) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //                 content: Text('Error: ${state.error}'),
  //                 backgroundColor: kErrorColor),
  //           );
  //         }
  //       },
  //       builder: (context, state) {
  //         return Scaffold(
  //           appBar: AppBar(
  //             backgroundColor: kPrimaryColor,
  //             elevation: 0,
  //             leading: IconButton(
  //               icon: const Icon(Icons.arrow_back, color: Colors.white),
  //               onPressed: () => Navigator.of(context).pop(),
  //             ),
  //             title: Text(medicine.name,
  //                 style: const TextStyle(color: Colors.white)),
  //             actions: [
  //               IconButton(
  //                 icon: const Icon(Icons.edit),
  //                 onPressed: () => _showEditDialog(context),
  //               ),
  //               IconButton(
  //                 icon: const Icon(Icons.delete),
  //                 onPressed: () => _showRemoveDialog(context),
  //               ),
  //             ],
  //           ),
  //           body: CustomScrollView(
  //             slivers: [
  //               SliverToBoxAdapter(
  //                 child: _buildHeader(),
  //               ),
  //               SliverPadding(
  //                 padding: const EdgeInsets.all(16.0),
  //                 sliver: SliverGrid(
  //                   gridDelegate:
  //                       const SliverGridDelegateWithFixedCrossAxisCount(
  //                     crossAxisCount: 2,
  //                     childAspectRatio: 1.5,
  //                     crossAxisSpacing: 16,
  //                     mainAxisSpacing: 16,
  //                   ),
  //                   delegate: SliverChildListDelegate([
  //                     _buildInfoCard(
  //                         'Pill Name', medicine.name, Icons.medication),
  //                     _buildInfoCard(
  //                         'Pill Dosage', medicine.dosage, Icons.straighten),
  //                     _buildInfoCard(
  //                         'Next Dose', _getNextDoseTime(), Icons.access_time),
  //                     _buildInfoCard('Quantity', '${medicine.quantity} left',
  //                         Icons.inventory),
  //                   ]),
  //                 ),
  //               ),
  //               SliverToBoxAdapter(
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(16.0),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       _buildDoseInfo(),
  //                       const SizedBox(height: 24),
  //                       _buildProgramInfo(),
  //                       const SizedBox(height: 24),
  //                       _buildQuantityInfo(),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           floatingActionButton: FloatingActionButton.extended(
  //             onPressed: () => _showEditDialog(context),
  //             icon: const Icon(Icons.edit),
  //             label: const Text('Change Schedule'),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
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

  // Widget _buildHeader() {
  //   return Container(
  //     color: kPrimaryColor,
  //     padding: const EdgeInsets.all(24.0),
  //     child: Row(
  //       children: [
  //         _buildMedicineImage(),
  //         const SizedBox(width: 24),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(medicine.name,
  //                   style: const TextStyle(
  //                       fontSize: 24,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.white)),
  //               const SizedBox(height: 8),
  //               Text(medicine.dosage,
  //                   style:
  //                       const TextStyle(fontSize: 18, color: Colors.white70)),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildInfoCard(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  // Widget _buildInfoCard(String title, String value, IconData icon) {
  //   return Card(
  //     elevation: 2,
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text(title,
  //               style: TextStyle(fontSize: 14, color: Colors.grey[600])),
  //           Icon(icon, size: 32, color: kPrimaryColor),
  //           const SizedBox(height: 3),
  //           Text(
  //             value,
  //             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //             textAlign: TextAlign.center,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildMedicineImage() {
  //   return Center(
  //     child: Container(
  //       width: 100,
  //       height: 100,
  //       decoration: BoxDecoration(
  //         color: _getColor(medicine.color),
  //         shape: BoxShape.circle,
  //       ),
  //       child: Image.asset(
  //         _getShapeImagePath(medicine.shape),
  //         color: Colors.white,
  //         width: 60,
  //         height: 60,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildInfoCard(String title, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(title, style: AppFonts.cardSubtitle),
  //         Text(value, style: AppFonts.cardTitle),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDoseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dose', style: AppFonts.cardTitle),
        Text(
            '${medicine.scheduleTimes.length} times | ${medicine.scheduleTimes.map((t) => DateFormat('h:mm a').format(t)).join(', ')}',
            style: AppFonts.cardSubtitle),
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
    int totalQuantity = medicine.quantity *
        medicine.scheduleTimes.length *
        medicine.endDate.difference(medicine.startDate).inDays;
    int remainingDays = medicine.endDate.difference(DateTime.now()).inDays;
    int remainingQuantity =
        medicine.quantity * medicine.scheduleTimes.length * remainingDays;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quantity', style: AppFonts.cardTitle),
        Text('Total $totalQuantity capsules | $remainingQuantity capsules left',
            style: AppFonts.cardSubtitle),
      ],
    );
  }

  Widget _buildChangeScheduleButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showEditDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: const Text('Change Schedule'),
      ),
    );
  }

  String _getNextDoseTime() {
    DateTime now = DateTime.now();
    for (DateTime time in medicine.scheduleTimes) {
      if (time.isAfter(now)) {
        return DateFormat('h:mm a').format(time);
      }
    }
    return DateFormat('h:mm a').format(medicine.scheduleTimes.first);
  }

  void _showEditDialog(BuildContext context) {
    TextEditingController nameController =
        TextEditingController(text: medicine.name);
    TextEditingController dosageController =
        TextEditingController(text: medicine.dosage);
    TextEditingController quantityController =
        TextEditingController(text: medicine.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Medicine'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Medicine Name'),
              ),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(labelText: 'Dosage'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              // Add more fields as needed
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Medicine updatedMedicine = Medicine(
                id: medicine.id,
                name: nameController.text,
                dosage: dosageController.text,
                quantity:
                    int.tryParse(quantityController.text) ?? medicine.quantity,
                startDate: medicine.startDate,
                endDate: medicine.endDate,
                shape: medicine.shape,
                color: medicine.color,
                scheduleTimes: medicine.scheduleTimes,
                isBeforeFood: medicine.isBeforeFood,
              );
              context
                  .read<MedicineBloc>()
                  .add(UpdateMedicine(medicine: updatedMedicine));
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Medicine'),
        content: const Text('Are you sure you want to remove this medicine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<MedicineBloc>()
                  .add(RemoveMedicine(medicineId: medicine.id));
              Navigator.pop(context);
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
