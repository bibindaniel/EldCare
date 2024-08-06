import 'dart:io';
import 'package:eldcare/elduser/blocs/userprofile/userprofile_bloc.dart';
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

class PharmacistProfileUpdatePage extends StatefulWidget {
  final String pharmacistId;

  const PharmacistProfileUpdatePage({super.key, required this.pharmacistId});

  @override
  PharmacistProfileUpdatePageState createState() =>
      PharmacistProfileUpdatePageState();
}

class PharmacistProfileUpdatePageState
    extends State<PharmacistProfileUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _houseNameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    context
        .read<PharmacistProfileBloc>()
        .add(LoadPharmacistProfile(widget.pharmacistId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile',
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
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: kSuccessColor,
              ),
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
          .add(UploadProfileImage(File(image.path)) as PharmacistProfileEvent);
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
              controller: _nameController,
              label: 'Name',
              validator: validateName,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _emailController,
              label: 'Email',
              validator: validateEmail,
            ),
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
            CustomTextFormField(
              controller: _postalCodeController,
              label: 'Postal Code',
              keyboardType: TextInputType.number,
              validator: validatePostalCode,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _licenseNumberController,
              label: 'License Number',
              validator: validateLicenseNumber,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Update Profile',
              onPressed: () => _updateProfile(pharmacistProfile),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProfile(PharmacistProfile pharmacistProfile) {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = pharmacistProfile.copyWith(
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

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Invalid name';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
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
      return 'House Name is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return 'Invalid house name';
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

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Invalid age';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Invalid phone number';
    }
    return null;
  }

  String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal Code is required';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Invalid postal code';
    }
    return null;
  }

  String? validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'License Number is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Invalid license number';
    }
    return null;
  }
}
