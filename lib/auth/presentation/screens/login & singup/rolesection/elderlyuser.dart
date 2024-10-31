import 'package:eldcare/core/theme/routes/myroutes.dart';
import 'package:eldcare/auth/domain/entities/user_details.dart';
import 'package:eldcare/auth/presentation/blocs/user_details/user_details_dart_bloc.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/auth/presentation/widgets/textboxwidget.dart';
import 'package:eldcare/auth/presentation/widgets/button_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:lottie/lottie.dart';

class ElderlyUserDetailsScreen extends StatelessWidget {
  ElderlyUserDetailsScreen({super.key});
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _houseNameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _phoneNumnerCodeController =
      TextEditingController();
  final String _selectedBloodType = 'A+';

  String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }
    // Add more specific validation if needed
    // Example: Validate if city contains only alphabetic characters and spaces
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Invalid city';
    }
    return null;
  }

  String? validateStreet(String? value) {
    if (value == null || value.isEmpty) {
      return 'Street is required';
    }
    // Add more specific validation if needed
    // Example: Validate if street contains only alphanumeric characters and spaces
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return 'Invalid street';
    }
    return null;
  }

  String? validateHouseName(String? value) {
    if (value == null || value.isEmpty) {
      return 'House name is required';
    }
    // Add more specific validation if needed
    // Example: Validate if house name contains only alphanumeric characters and spaces
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return 'Invalid house name';
    }
    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }

    // Validate if age is a valid number
    int? age = int.tryParse(value);
    if (age == null) {
      return 'Age must be a valid number';
    }

    // Validate if age is between 10 and 120
    if (age < 10 || age > 120) {
      return 'Age must be between 10 and 120';
    }

    return null;
  }

  String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'State is required';
    }
    // Add more specific validation if needed
    // Example: Validate if state contains only alphabetic characters and spaces
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Invalid state';
    }
    return null;
  }

  String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }
    // Example: Validate if postal code is exactly 6 digits (Indian postal code)
    if (value.length != 6 || int.tryParse(value) == null) {
      return 'Postal code must be a 6-digit number';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Example: Validate Indian phone numbers starting with 7, 8, or 9 and exactly 10 digits
    if (!RegExp(r'^[789]\d{9}$').hasMatch(value)) {
      return 'Invalid Indian phone number';
    }
    return null;
  }

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
    return BlocProvider(
      create: (context) => UserDetailsDartBloc(),
      child: BlocConsumer<UserDetailsDartBloc, UserDetailsDartState>(
        listener: (context, state) {
          if (state is UserDetailsDartSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Details saved successfully')),
            );
            Navigator.of(context).pushNamedAndRemoveUntil(
              Myroutes.home,
              (Route<dynamic> route) => false,
            ); // Or navigate to the next screen
          } else if (state is UserDetailsDartFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
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
                          style: AppFonts.bodyText1),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        controller: _ageController,
                        label: 'Age',
                        keyboardType: TextInputType.number,
                        validator: validateAge,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _phoneNumnerCodeController,
                        label: 'Phone',
                        keyboardType: TextInputType.number,
                        validator: validatePhoneNumber,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _houseNameController,
                        label: 'House Name',
                        validator: validateHouseName,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _streetController,
                        label: 'Street',
                        validator: validateStreet,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              controller: _cityController,
                              label: 'City',
                              validator: validateCity,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextFormField(
                              controller: _stateController,
                              label: 'State',
                              validator: validateState,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              controller: _postalCodeController,
                              label: 'Postal Code',
                              keyboardType: TextInputType.number,
                              validator: validatePostalCode,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
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
                              onChanged: (String? newValue) {},
                              validator: (value) => value == null
                                  ? 'Please select your blood type'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Save Details',
                        onPressed: state is UserDetailsDartLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<UserDetailsDartBloc>().add(
                                        SubmitUserDetails(
                                          UserDetails(
                                            role: '1',
                                            age: _ageController.text,
                                            phone:
                                                _phoneNumnerCodeController.text,
                                            houseName:
                                                _houseNameController.text,
                                            street: _streetController.text,
                                            city: _cityController.text,
                                            state: _stateController.text,
                                            postalCode:
                                                _postalCodeController.text,
                                            bloodType: _selectedBloodType,
                                          ),
                                        ),
                                      );
                                }
                              },
                      ),
                      if (state is UserDetailsDartLoading)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
