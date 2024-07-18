import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/routes/elduser_routes.dart';
import 'package:eldcare/elduser/blocs/medicine/medicine_bloc.dart';
import 'package:eldcare/elduser/models/medicine.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String _selectedShape = '';
  String _selectedColorName = 'White';

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
          title: const Text('Add New Medicine',
              style: TextStyle(color: Colors.white)),
        ),
        body: BlocConsumer<MedicineBloc, MedicineState>(
          listener: (context, state) {
            if (state is MedicineSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Medicine added successfully')),
              );
              Navigator.pushNamed(context, EldUserRoutes.scheduleMedicine);
            } else if (state is MedicineError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}')),
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
                      const Text('Create a New Schedule',
                          style: TextStyle(color: Colors.white, fontSize: 24)),
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
                      color: Colors.white,
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
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField('Medicine Name', _nameController),
                            const SizedBox(height: 20),
                            _buildTextField('Dosage', _dosageController),
                            const SizedBox(height: 20),
                            _buildTextField('Quantity', _quantityController),
                            const SizedBox(height: 20),
                            const Text('Duration',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateField(
                                      'Start Date', _startDate, (date) {
                                    setState(() => _startDate = date);
                                  }),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildDateField('End Date', _endDate,
                                      (date) {
                                    setState(() => _endDate = date);
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text('Shape',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildShapeSelector(),
                            const SizedBox(height: 20),
                            const Text('Color',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildColorSelector(),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: kPrimaryColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    final medicine = Medicine(
                                      name: _nameController.text,
                                      dosage: _dosageController.text,
                                      quantity:
                                          int.parse(_quantityController.text),
                                      startDate: _startDate,
                                      endDate: _endDate,
                                      shape: _selectedShape,
                                      color: _selectedColorName,
                                    );
                                    context
                                        .read<MedicineBloc>()
                                        .add(AddMedicine(medicine));
                                  }
                                },
                                child: const Text('Next: Set Schedule',
                                    style: TextStyle(fontSize: 18)),
                              ),
                            ),
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(
      String label, DateTime date, Function(DateTime) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      controller:
          TextEditingController(text: DateFormat('MMM dd, yyyy').format(date)),
      readOnly: true,
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        if (picked != null && picked != date) {
          onChanged(picked);
        }
      },
    );
  }

  Widget _buildShapeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildShapeButton(context, 'assets/images/pills/meds.png', 'circle'),
        _buildShapeButton(
            context, 'assets/images/pills/round-pill.png', 'rectangle'),
        _buildShapeButton(
            context, 'assets/images/pills/oval-pill.png', 'triangle'),
        _buildShapeButton(context, 'assets/images/pills/inhaler.png', 'square'),
        _buildShapeButton(context, 'assets/images/pills/eye-drops.png', 'oval'),
        _buildShapeButton(
            context, 'assets/images/pills/pills-bottle.png', 'bottle'),
      ],
    );
  }

  Widget _buildShapeButton(
      BuildContext context, String imagePath, String shape) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedShape = shape;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
              color: _selectedShape == shape ? kPrimaryColor : Colors.grey,
              width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            Image.asset(imagePath, width: 40, height: 40, color: Colors.black),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: medicineColors.map((colorData) {
        return _buildColorButton(
            context, colorData['color'], colorData['name']);
      }).toList(),
    );
  }

  Widget _buildColorButton(
      BuildContext context, Color color, String colorName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColorName = colorName;
        });
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
                color: _selectedColorName == colorName
                    ? kPrimaryColor
                    : Colors.grey,
                width: 2),
          ),
        ),
      ),
    );
  }
}
