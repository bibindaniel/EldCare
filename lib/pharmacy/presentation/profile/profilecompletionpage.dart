import 'dart:io';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_event.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_state.dart';
import 'package:eldcare/pharmacy/model/pharmacist.dart';
import 'package:eldcare/pharmacy/presentation/homescreen/pharmhomescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:eldcare/auth/presentation/widgets/textboxwidget.dart';
import 'package:eldcare/auth/presentation/widgets/button_widget.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';

class PharmacistProfileCompletionPage extends StatefulWidget {
  final String pharmacistId;

  const PharmacistProfileCompletionPage(
      {super.key, required this.pharmacistId});

  @override
  PharmacistProfileCompletionPageState createState() =>
      PharmacistProfileCompletionPageState();
}

class PharmacistProfileCompletionPageState
    extends State<PharmacistProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;
  late TextEditingController _houseNameController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _licenseNumberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _ageController = TextEditingController();
    _phoneController = TextEditingController();
    _houseNameController = TextEditingController();
    _streetController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _postalCodeController = TextEditingController();
    _licenseNumberController = TextEditingController();
    context
        .read<PharmacistProfileBloc>()
        .add(LoadPharmacistProfile(widget.pharmacistId));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _houseNameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Profile',
            style: AppFonts.headline2.copyWith(color: Colors.white)),
        backgroundColor: kPrimaryColor,
      ),
      body: BlocConsumer<PharmacistProfileBloc, PharmacistProfileState>(
        listener: (context, state) {
          if (state is PharmacistProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          } else if (state is PharmacistProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const PharmacistHomeScreen()),
            );
          }
        },
        builder: (context, state) {
          if (state is PharmacistProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PharmacistProfileLoaded ||
              state is PharmacistProfileUpdated) {
            final pharmacistProfile = (state is PharmacistProfileLoaded)
                ? state.pharmacistProfile
                : (state as PharmacistProfileUpdated).pharmacistProfile;
            _populateFields(pharmacistProfile);
            return _buildForm(pharmacistProfile);
          } else {
            return const Center(child: Text('Failed to load profile'));
          }
        },
      ),
    );
  }

  Widget _buildForm(PharmacistProfile pharmacistProfile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileImage(context, pharmacistProfile.profileImageUrl),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _ageController,
              label: 'Age',
              keyboardType: TextInputType.number,
              validator: validateAge,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _phoneController,
              label: 'Phone',
              keyboardType: TextInputType.phone,
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
                  child: CustomTextFormField(
                    controller: _licenseNumberController,
                    label: 'License Number',
                    validator: validateLicenseNumber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Complete Profile',
              onPressed: _updateProfile,
            ),
          ],
        ),
      ),
    );
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = PharmacistProfile(
        id: widget.pharmacistId,
        name: _nameController.text,
        email: _emailController.text,
        age: _ageController.text,
        phone: _phoneController.text,
        houseName: _houseNameController.text,
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        postalCode: _postalCodeController.text,
        licenseNumber: _licenseNumberController.text,
        isProfileComplete: true,
      );
      context
          .read<PharmacistProfileBloc>()
          .add(UpdatePharmacistProfile(updatedProfile));
    }
  }

  Widget _buildProfileImage(BuildContext context, String? imageUrl) {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
        child:
            imageUrl == null ? const Icon(Icons.add_a_photo, size: 40) : null,
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      context
          .read<PharmacistProfileBloc>()
          .add(UploadPharmacistProfileImage(File(image.path)));
    }
  }

  void _populateFields(PharmacistProfile pharmacistProfile) {
    _nameController.text = pharmacistProfile.name ?? '';
    _emailController.text = pharmacistProfile.email ?? '';
    _ageController.text = pharmacistProfile.age ?? '';
    _phoneController.text = pharmacistProfile.phone ?? '';
    _houseNameController.text = pharmacistProfile.houseName ?? '';
    _streetController.text = pharmacistProfile.street ?? '';
    _cityController.text = pharmacistProfile.city ?? '';
    _stateController.text = pharmacistProfile.state ?? '';
    _postalCodeController.text = pharmacistProfile.postalCode ?? '';
    _licenseNumberController.text = pharmacistProfile.licenseNumber ?? '';
  }

  String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Invalid city';
    }
    return null;
  }

  String? validateStreet(String? value) {
    if (value == null || value.isEmpty) {
      return 'Street is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return 'Invalid street';
    }
    return null;
  }

  String? validateHouseName(String? value) {
    if (value == null || value.isEmpty) {
      return 'House name is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return 'Invalid house name';
    }
    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    int? age = int.tryParse(value);
    if (age == null || age <= 0) {
      return 'Invalid age';
    }
    return null;
  }

  String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Invalid postal code';
    }
    return null;
  }

  String? validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'License number is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Invalid license number';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[6789]\d{9}$').hasMatch(value)) {
      return 'Invalid Indian phone number';
    }
    return null;
  }

  String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'State is required';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Invalid state';
    }
    return null;
  }
}
