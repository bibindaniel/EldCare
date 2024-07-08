import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/presentation/widgets/textboxwidget.dart';
import 'package:eldcare/presentation/widgets/button_widget.dart';

class ElderlyUserDetailsScreen extends StatefulWidget {
  @override
  _ElderlyUserDetailsScreenState createState() =>
      _ElderlyUserDetailsScreenState();
}

class _ElderlyUserDetailsScreenState extends State<ElderlyUserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _houseNameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _medicalConditionsController =
      TextEditingController();
  String? _selectedBloodType;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details',
            style: AppFonts.headline2.copyWith(color: Colors.white)),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Please fill in your details:',
                    style: AppFonts.coloredbodyText1),
                const SizedBox(height: 24),
                CustomTextFormField(
                  controller: _ageController,
                  label: 'Age',
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your age' : null,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _houseNameController,
                  label: 'House Name',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your house name' : null,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _streetController,
                  label: 'Street',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your street' : null,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _cityController,
                  label: 'City',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your city' : null,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _stateController,
                  label: 'State',
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your state' : null,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _postalCodeController,
                  label: 'Postal Code',
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your postal code' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Blood Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedBloodType,
                  items: _bloodTypes.map((String bloodType) {
                    return DropdownMenuItem<String>(
                      value: bloodType,
                      child: Text(bloodType),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBloodType = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select your blood type' : null,
                ),
                const SizedBox(height: 24),
                CustomTextFormField(
                  controller: _medicalConditionsController,
                  label: 'Medical Conditions (if any)',
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Save Details',
                  onPressed: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
    }
  }

  // void _submitForm() {
  // if (_formKey.currentState!.validate()) {
  //   // Process the form data
  //   // You would typically save this data to your backend or local storage
  //   Map<String, dynamic> elderlyUserData = {
  //     'fullName': _fullNameController.text,
  //     'age': _ageController.text,
  //     'address': _addressController.text,
  //     'bloodType': _selectedBloodType,
  //     'emergencyContactName': _emergencyContactNameController.text,
  //     'emergencyContactNumber': _emergencyContactNumberController.text,
  //     'medicalConditions': _medicalConditionsController.text,
  //   };

  //   // TODO: Save elderlyUserData to your backend or local storage

  //   // Show a success message
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Details saved successfully!')),
  //   );

  //   // Navigate to the next screen or dashboard
  //   // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ElderlyUserDashboard()));
  // }
  // }

  // @override
  // void dispose() {
  //   _fullNameController.dispose();
  //   _ageController.dispose();
  //   _addressController.dispose();
  //   _emergencyContactNameController.dispose();
  //   _emergencyContactNumberController.dispose();
  //   _medicalConditionsController.dispose();
  //   super.dispose();
  // }
}
