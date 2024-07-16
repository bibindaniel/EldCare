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
  const AddMedicinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MedicineAddBloc(),
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
                              'Medicine Name', state.name, 'name', context),
                          const SizedBox(height: 20),
                          _buildTextField(
                              'Dosage', state.dosage, 'dosage', context),
                          const SizedBox(height: 20),
                          _buildTextField(
                              'Quantity', state.quantity, 'quantity', context),
                          const SizedBox(height: 20),
                          _buildTextField(
                              'Number of pills per day',
                              state.pillsPerDay.toString(),
                              'pillsPerDay',
                              context,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 20),
                          Text('Pill Times', style: AppFonts.headline3Dark),
                          ...List.generate(
                            state.pillsPerDay,
                            (index) => ListTile(
                              title: Text('Pill ${index + 1}'),
                              trailing:
                                  Text(state.pillTimes[index].format(context)),
                              onTap: () async {
                                TimeOfDay? newTime = await showTimePicker(
                                  context: context,
                                  initialTime: state.pillTimes[index],
                                );
                                if (newTime != null) {
                                  context.read<MedicineAddBloc>().add(
                                      MedicineFieldChanged('pillTime',
                                          {'index': index, 'time': newTime}));
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('Duration', style: AppFonts.headline3Dark),
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
                              _buildShapeButton(context,
                                  'assets/images/pills/meds.png', 'circle'),
                              _buildShapeButton(
                                  context,
                                  'assets/images/pills/round-pill.png',
                                  'rectangle'),
                              _buildShapeButton(
                                  context,
                                  'assets/images/pills/oval-pill.png',
                                  'triangle'),
                              _buildShapeButton(context,
                                  'assets/images/pills/inhaler.png', 'square'),
                              _buildShapeButton(context,
                                  'assets/images/pills/eye-drops.png', 'oval'),
                              _buildShapeButton(
                                  context,
                                  'assets/images/pills/pills-bottle.png',
                                  'oval'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text('Color', style: AppFonts.headline3Dark),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildColorButton(
                                  context, Colors.green[100]!, 'green'),
                              const SizedBox(width: 16),
                              _buildColorButton(
                                  context, Colors.pink[100]!, 'pink'),
                              const SizedBox(width: 16),
                              _buildColorButton(
                                  context, Colors.blue[100]!, 'blue'),
                              const SizedBox(width: 16),
                              _buildColorButton(
                                  context, Colors.orange[100]!, 'orange'),
                              const SizedBox(width: 16),
                              _buildColorButton(
                                  context, Colors.yellow[100]!, 'yellow'),
                            ],
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
                              onPressed: () {
                                context
                                    .read<MedicineAddBloc>()
                                    .add(MedicineSubmitted());
                              },
                              child: const Text('Add Schedule',
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
    );
  }

  Widget _buildTextField(
      String label, String value, String field, BuildContext context,
      {TextInputType? keyboardType}) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      keyboardType: keyboardType,
      controller: TextEditingController(text: value),
      onChanged: (value) => context
          .read<MedicineAddBloc>()
          .add(MedicineFieldChanged(field, value)),
    );
  }

  Widget _buildDateField(
      String label, DateTime date, String field, BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      controller:
          TextEditingController(text: DateFormat('MMM dd, yyyy').format(date)),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (pickedDate != null && pickedDate != date) {
          context
              .read<MedicineAddBloc>()
              .add(MedicineFieldChanged(field, pickedDate));
        }
      },
    );
  }

  Widget _buildShapeButton(
      BuildContext context, String imagePath, String shape) {
    return GestureDetector(
      onTap: () => context
          .read<MedicineAddBloc>()
          .add(MedicineFieldChanged('shape', shape)),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: kPrimaryColor),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Image.asset(
          imagePath,
          width: 10,
          height: 10,
          color: kPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildColorButton(
      BuildContext context, Color color, String colorName) {
    return GestureDetector(
      onTap: () => context
          .read<MedicineAddBloc>()
          .add(MedicineFieldChanged('color', color)),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
