import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/elduser/blocs/medicine_add/medicine_add_bloc.dart';
import 'package:eldcare/elduser/blocs/medicine_add/medicine_add_event.dart';
import 'package:eldcare/elduser/blocs/medicine_add/medicine_add_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class AddMedicinePage extends StatelessWidget {
  AddMedicinePage({super.key});
  final List<Map<String, dynamic>> medicineColors = [
    {'name': 'White', 'color': Colors.white},
    {'name': 'Cream', 'color': const Color(0xFFFFFDD0)},
    {'name': 'Yellow', 'color': Colors.yellow},
    {'name': 'Orange', 'color': Colors.orange},
    {'name': 'Pink', 'color': Colors.pink},
    {'name': 'Red', 'color': Colors.red},
    {'name': 'Light Blue', 'color': Colors.lightBlue},
    {'name': 'Dark Blue', 'color': Colors.blue},
    {'name': 'Green', 'color': Colors.green},
    {'name': 'Brown', 'color': Colors.brown},
    {'name': 'Gray', 'color': Colors.grey},
    {'name': 'Black', 'color': Colors.black},
    {'name': 'Purple', 'color': Colors.purple},
  ];
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MedicineAddBloc(),
      child: BlocListener<MedicineAddBloc, MedicineAddState>(
        listener: (context, state) {
          if (state.status == MedicineAddStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Medicine added successfully')),
            );
            Navigator.of(context).pop(); // Go back to previous screen
          } else if (state.status == MedicineAddStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add medicine: ${state.error}')),
            );
          }
        },
        child: Scaffold(
          backgroundColor: kPrimaryColor,
          appBar: AppBar(
            backgroundColor: kPrimaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: kWhiteColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Add New Medicine', style: AppFonts.headline3),
          ),
          body: BlocBuilder<MedicineAddBloc, MedicineAddState>(
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Create a New Schedule',
                            style: AppFonts.headline3),
                        Lottie.asset(
                          'assets/animations/medical.json',
                          width: 80,
                          height: 80,
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
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                                'Medicine Name', state.name, 'name', context,
                                useDelayedUpdate: true),
                            const SizedBox(height: 20),
                            _buildTextField(
                                'Dosage', state.dosage, 'dosage', context,
                                keyboardType: TextInputType.number,
                                useDelayedUpdate: true),
                            const SizedBox(height: 20),
                            _buildTextField(
                                'Quantity', state.quantity, 'quantity', context,
                                keyboardType: TextInputType.number,
                                useDelayedUpdate: true),
                            const SizedBox(height: 20),
                            _buildTextField(
                              'Number of pills per day',
                              state.pillsPerDay.toString(),
                              'pillsPerDay',
                              context,
                              keyboardType: TextInputType.number,
                              useDelayedUpdate: true,
                            ),
                            const SizedBox(height: 20),
                            const Text('Pill Times',
                                style: AppFonts.headline3Dark),
                            ...List.generate(
                              state.pillsPerDay,
                              (index) => ListTile(
                                title: Text('Pill ${index + 1}'),
                                trailing: Text(
                                    state.pillTimes[index].format(context)),
                                onTap: () async {
                                  TimeOfDay? newTime = await showTimePicker(
                                    context: context,
                                    initialTime: state.pillTimes[index],
                                  );
                                  if (newTime != null) {
                                    context.read<MedicineAddBloc>().add(
                                          MedicineFieldChanged(
                                            'pillTime',
                                            {'index': index, 'time': newTime},
                                          ),
                                        );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text('Duration',
                                style: AppFonts.headline3Dark),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateField('Start Date',
                                      state.startDate, 'startDate', context),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildDateField('End Date',
                                      state.endDate, 'endDate', context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text('Shape', style: AppFonts.headline3Dark),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildShapeButton(
                                    context,
                                    'assets/images/pills/meds.png',
                                    'circle',
                                    state.shape),
                                _buildShapeButton(
                                    context,
                                    'assets/images/pills/round-pill.png',
                                    'rectangle',
                                    state.shape),
                                _buildShapeButton(
                                    context,
                                    'assets/images/pills/oval-pill.png',
                                    'triangle',
                                    state.shape),
                                _buildShapeButton(
                                    context,
                                    'assets/images/pills/inhaler.png',
                                    'square',
                                    state.shape),
                                _buildShapeButton(
                                    context,
                                    'assets/images/pills/eye-drops.png',
                                    'oval',
                                    state.shape),
                                _buildShapeButton(
                                    context,
                                    'assets/images/pills/pills-bottle.png',
                                    'bottle',
                                    state.shape),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text('Color', style: AppFonts.headline3Dark),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: medicineColors.map((colorData) {
                                return _buildColorButton(
                                    context,
                                    colorData['color'],
                                    colorData['name'],
                                    state.color);
                              }).toList(),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: kWhiteColor,
                                  backgroundColor: kPrimaryColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed:
                                    state.status == MedicineAddStatus.submitting
                                        ? null
                                        : () => context
                                            .read<MedicineAddBloc>()
                                            .add(MedicineSubmitted()),
                                child:
                                    state.status == MedicineAddStatus.submitting
                                        ? const CircularProgressIndicator()
                                        : const Text('Add Schedule',
                                            style: TextStyle(fontSize: 18)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    String field,
    BuildContext context, {
    TextInputType? keyboardType,
    bool useDelayedUpdate = false,
  }) {
    final controller = TextEditingController(text: value);

    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      keyboardType: keyboardType,
      controller: controller,
      onChanged: useDelayedUpdate
          ? null
          : (value) => context
              .read<MedicineAddBloc>()
              .add(MedicineFieldChanged(field, value)),
      onEditingComplete: useDelayedUpdate
          ? () {
              context
                  .read<MedicineAddBloc>()
                  .add(MedicineFieldCompleted(field, controller.text));
              FocusScope.of(context).unfocus();
            }
          : null,
    );
  }

  Widget _buildDateField(
      String label, DateTime date, String field, BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: DateFormat('MMM dd, yyyy').format(date),
    );

    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      controller: controller,
      readOnly: true, // Makes the text field read-only
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (pickedDate != null && pickedDate != date) {
          // Update the text field
          controller.text = DateFormat('MMM dd, yyyy').format(pickedDate);

          // Update the bloc state
          context
              .read<MedicineAddBloc>()
              .add(MedicineFieldCompleted(field, pickedDate));
        }
      },
    );
  }

  Widget _buildShapeButton(BuildContext context, String imagePath, String shape,
      String currentShape) {
    return GestureDetector(
      onTap: () {
        context
            .read<MedicineAddBloc>()
            .add(MedicineFieldChanged('shape', shape));
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: currentShape == shape ? kPrimaryColor : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            Image.asset(imagePath, width: 40, height: 40, color: kBlackColor),
      ),
    );
  }

  Widget _buildColorButton(
      BuildContext context, Color color, String colorName, Color currentColor) {
    final bool isDark =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
    return GestureDetector(
      onTap: () {
        context
            .read<MedicineAddBloc>()
            .add(MedicineFieldChanged('color', color));
      },
      child: Tooltip(
        message: colorName,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: currentColor == color ? kPrimaryColor : Colors.grey,
              width: 2,
            ),
          ),
          child: currentColor == color
              ? Icon(Icons.check, color: isDark ? Colors.white : Colors.black)
              : null,
        ),
      ),
    );
  }
}
