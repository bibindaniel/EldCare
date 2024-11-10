import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/elduser/blocs/medicine/medicine_bloc.dart';
import 'package:eldcare/elduser/models/medicine.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditMedicinePage extends StatefulWidget {
  final Medicine medicine;

  const EditMedicinePage({super.key, required this.medicine});

  @override
  EditMedicinePageState createState() => EditMedicinePageState();
}

class EditMedicinePageState extends State<EditMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController frequencyController;
  late DateTime _startDate;
  late DateTime _endDate;
  late String _selectedShape;
  late String _selectedColorName;
  late int _frequency;
  late bool _isBeforeFood;
  int _currentStep = 0;
  late List<MedicineSchedule> _schedules;
  bool _sameDosageForAll = true;
  late TextEditingController _commonDosageController;
  final Map<int, Map<String, TextEditingController>> _scheduleControllers = {};
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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine.name);
    _quantityController =
        TextEditingController(text: widget.medicine.quantity.toString());
    _startDate = widget.medicine.startDate;
    _endDate = widget.medicine.endDate;
    _selectedShape = widget.medicine.shape;
    _selectedColorName = widget.medicine.color;
    _frequency = widget.medicine.schedules.length;
    _schedules = List.from(widget.medicine.schedules);
    _isBeforeFood = widget.medicine.isBeforeFood;
    frequencyController = TextEditingController(text: _frequency.toString());
    _commonDosageController =
        TextEditingController(text: _schedules.first.dosage);
    _sameDosageForAll = _schedules
        .every((schedule) => schedule.dosage == _schedules.first.dosage);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    frequencyController.dispose();
    _commonDosageController.dispose();
    super.dispose();
  }

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
          title: const Text('Edit Medicine',
              style: TextStyle(color: Colors.white)),
        ),
        body: BlocConsumer<MedicineBloc, MedicineState>(
          listener: (context, state) {
            if (state is MedicineSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Medicine updated successfully'),
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
                          'Edit and Reschedule Medicine',
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
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: kPrimaryColor,
                        ),
                      ),
                      child: Stepper(
                        currentStep: _currentStep,
                        onStepContinue: () {
                          if (_currentStep < 1) {
                            if (_validateFirstStep(context)) {
                              setState(() => _currentStep += 1);
                            }
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Medicine Name', _nameController, _validateName),
            const SizedBox(height: 20),
            _buildTextField('Quantity', _quantityController, _validateQuantity),
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
        TextFormField(
          controller: frequencyController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Frequency',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          validator: (value) {
            int? frequency = int.tryParse(value ?? '');
            if (frequency == null || frequency <= 0 || frequency > 5) {
              return 'Please enter a valid number between 1 and 5';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              int frequency = int.tryParse(value) ?? 1;
              if (frequency > 0 && frequency <= 5) {
                _frequency = frequency;
                _schedules = List.generate(
                  _frequency,
                  (index) => index < _schedules.length
                      ? _schedules[index]
                      : MedicineSchedule(
                          time: DateTime.now(),
                          dosage: _commonDosageController.text),
                );
                frequencyController.text = value;
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Please enter a valid number between 1 and 5'),
                    backgroundColor: kErrorColor,
                  ),
                );
              }
            });
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text('Same dosage for all times?'),
            const Spacer(),
            Switch(
              value: _sameDosageForAll,
              onChanged: (value) {
                setState(() {
                  _sameDosageForAll = value;
                  if (value) {
                    String commonDosage = _schedules.first.dosage;
                    _schedules = _schedules
                        .map((schedule) => MedicineSchedule(
                              time: schedule.time,
                              dosage: commonDosage,
                            ))
                        .toList();
                    _commonDosageController.text = commonDosage;
                  }
                });
              },
            ),
          ],
        ),
        if (_sameDosageForAll)
          TextFormField(
            controller: _commonDosageController,
            decoration: InputDecoration(
              labelText: 'Common Dosage',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the dosage';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _schedules = _schedules
                    .map((schedule) => MedicineSchedule(
                          time: schedule.time,
                          dosage: value,
                        ))
                    .toList();
              });
            },
          ),
        const SizedBox(height: 20),
        const Text('Set times and dosages:'),
        ..._schedules.asMap().entries.map((entry) {
          int idx = entry.key;
          MedicineSchedule schedule = entry.value;

          // Create persistent controllers for each schedule
          if (!_scheduleControllers.containsKey(idx)) {
            _scheduleControllers[idx] = {
              'time': TextEditingController(
                text: DateFormat.jm().format(schedule.time),
              ),
              'dosage': TextEditingController(
                text: schedule.dosage,
              ),
            };
          }

          final timeController = _scheduleControllers[idx]!['time']!;
          final dosageController = _scheduleControllers[idx]!['dosage']!;

          // Maintain cursor position
          dosageController.selection = TextSelection.fromPosition(
            TextPosition(offset: schedule.dosage.length),
          );

          return Column(
            children: [
              ListTile(
                title: TextFormField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'Time ${idx + 1}',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(schedule.time),
                        );
                        if (picked != null) {
                          setState(() {
                            _schedules[idx] = MedicineSchedule(
                              time: DateTime(
                                schedule.time.year,
                                schedule.time.month,
                                schedule.time.day,
                                picked.hour,
                                picked.minute,
                              ),
                              dosage: schedule.dosage,
                            );
                            timeController.text =
                                DateFormat.jm().format(_schedules[idx].time);
                          });
                        }
                      },
                    ),
                  ),
                  readOnly: true,
                ),
              ),
              if (!_sameDosageForAll)
                ListTile(
                  title: TextFormField(
                    controller: dosageController,
                    decoration: InputDecoration(
                      labelText: 'Dosage ${idx + 1}',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the dosage';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _schedules[idx] = MedicineSchedule(
                          time: schedule.time,
                          dosage: value,
                        );
                        // Maintain cursor position
                        dosageController.selection = TextSelection.fromPosition(
                          TextPosition(offset: value.length),
                        );
                      });
                    },
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: 20),
        const Text('Take medicine:'),
        RadioListTile(
          title: const Text('Before food'),
          value: true,
          groupValue: _isBeforeFood,
          onChanged: (bool? value) {
            setState(() {
              _isBeforeFood = value!;
            });
          },
        ),
        RadioListTile(
          title: const Text('After food'),
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
    bool isFirstStepValid = _validateFirstStep(context);

    if (!isFirstStepValid) {
      setState(() {
        _currentStep = 0;
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      final updatedMedicine = Medicine(
        id: widget.medicine.id,
        name: _nameController.text,
        quantity: int.parse(_quantityController.text),
        startDate: _startDate,
        endDate: _endDate,
        shape: _selectedShape,
        color: _selectedColorName,
        schedules: _schedules,
        isBeforeFood: _isBeforeFood,
      );

      context
          .read<MedicineBloc>()
          .add(UpdateMedicine(medicine: updatedMedicine));
    }
  }

  bool _validateFirstStep(BuildContext context) {
    bool isValid = true;

    if (_nameController.text.isEmpty) {
      isValid = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the medicine name'),
          backgroundColor: kErrorColor,
        ),
      );
    } else if (_quantityController.text.isEmpty ||
        int.tryParse(_quantityController.text) == null ||
        int.parse(_quantityController.text) <= 0) {
      isValid = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid quantity'),
          backgroundColor: kErrorColor,
        ),
      );
    } else if (_selectedShape.isEmpty) {
      isValid = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a medicine shape'),
          backgroundColor: kErrorColor,
        ),
      );
    } else if (_selectedColorName.isEmpty) {
      isValid = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a medicine color'),
          backgroundColor: kErrorColor,
        ),
      );
    } else if (_endDate.isBefore(_startDate)) {
      isValid = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be after start date'),
          backgroundColor: kErrorColor,
        ),
      );
    }

    return isValid;
  }

  Widget _buildTextField(String label, TextEditingController controller,
      String? Function(String?)? validator) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: kErrorColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: kSuccessColor,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: kErrorColor,
            width: 2.0,
          ),
        ),
      ),
      validator: validator,
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the medicine name';
    }
    return null;
  }

  String? _validateDosage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the dosage';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the quantity';
    }
    final quantity = int.tryParse(value);
    if (quantity == null || quantity <= 0) {
      return 'Please enter a valid quantity';
    }
    return null;
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
          lastDate: DateTime.now().add(const Duration(days: 365)),
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
            width: 2,
          ),
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
              color:
                  _selectedColorName == colorName ? kPrimaryColor : Colors.grey,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
