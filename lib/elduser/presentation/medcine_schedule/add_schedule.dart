import 'package:eldcare/core/theme/colors.dart';
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
  int _frequency = 1;
  List<TimeOfDay> _scheduleTimes = [TimeOfDay.now()];
  bool _isBeforeFood = true;
  int _currentStep = 0;

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
              Navigator.pop(context);
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
                      const Expanded(
                        child: Text(
                          'Add and Schedule Medicine',
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
                    child: Stepper(
                      currentStep: _currentStep,
                      onStepContinue: () {
                        if (_currentStep < 1) {
                          setState(() => _currentStep += 1);
                        } else {
                          _submitForm(context);
                        }
                      },
                      onStepCancel: () {
                        if (_currentStep > 0) {
                          setState(() => _currentStep -= 1);
                        }
                      },
                      steps: [
                        Step(
                          title: const Text('Medicine Details'),
                          content: _buildMedicineDetailsForm(),
                          isActive: _currentStep >= 0,
                        ),
                        Step(
                          title: const Text('Schedule'),
                          content: _buildScheduleForm(),
                          isActive: _currentStep >= 1,
                        ),
                      ],
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

  Widget _buildMedicineDetailsForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: _buildDateField('Start Date', _startDate, (date) {
                    setState(() => _startDate = date);
                  }),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildDateField('End Date', _endDate, (date) {
                    setState(() => _endDate = date);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Shape',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildShapeSelector(),
            const SizedBox(height: 20),
            const Text('Color',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildColorSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How many times a day?'),
        DropdownButton<int>(
          value: _frequency,
          items: [1, 2, 3, 4].map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value time(s)'),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _frequency = newValue!;
              _scheduleTimes =
                  List.generate(_frequency, (index) => TimeOfDay.now());
            });
          },
        ),
        SizedBox(height: 20),
        Text('Set times:'),
        ..._scheduleTimes.asMap().entries.map((entry) {
          int idx = entry.key;
          TimeOfDay time = entry.value;
          return ListTile(
            title: Text('Dose ${idx + 1}: ${time.format(context)}'),
            trailing: IconButton(
              icon: Icon(Icons.access_time),
              onPressed: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: time,
                );
                if (picked != null) {
                  setState(() {
                    _scheduleTimes[idx] = picked;
                  });
                }
              },
            ),
          );
        }),
        SizedBox(height: 20),
        Text('Take medicine:'),
        RadioListTile(
          title: Text('Before food'),
          value: true,
          groupValue: _isBeforeFood,
          onChanged: (bool? value) {
            setState(() {
              _isBeforeFood = value!;
            });
          },
        ),
        RadioListTile(
          title: Text('After food'),
          value: false,
          groupValue: _isBeforeFood,
          onChanged: (bool? value) {
            setState(() {
              _isBeforeFood = value!;
            });
          },
        ),
      ],
    );
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final medicine = Medicine(
        name: _nameController.text,
        dosage: _dosageController.text,
        quantity: int.parse(_quantityController.text),
        startDate: _startDate,
        endDate: _endDate,
        shape: _selectedShape,
        color: _selectedColorName,
      );

      List<DateTime> scheduleTimes = _scheduleTimes.map((time) {
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, time.hour, time.minute);
      }).toList();

      context.read<MedicineBloc>().add(AddAndScheduleMedicine(
            medicine: medicine,
            scheduleTimes: scheduleTimes,
            isBeforeFood: _isBeforeFood,
          ));
    }
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
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
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
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
              color: _selectedShape == shape ? kPrimaryColor : Colors.grey,
              width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          imagePath,
          width: 40,
          height: 40,
          color: Colors.black,
          fit: BoxFit.contain,
        ),
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
