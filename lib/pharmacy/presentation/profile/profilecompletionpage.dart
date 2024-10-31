import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_event.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_state.dart';
import 'package:eldcare/pharmacy/model/pharmacist.dart';
import 'package:eldcare/pharmacy/presentation/homescreen/pharmhomescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/presentation/widgets/textboxwidget.dart';
import '../../../auth/presentation/widgets/button_widget.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/font.dart';

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
        title: Text('Complete Profile',
            style: AppFonts.headline2.copyWith(color: Colors.white)),
        backgroundColor: kPrimaryColor,
      ),
      body: BlocConsumer<PharmacistProfileBloc, PharmacistProfileState>(
        listener: (context, state) {
          if (state is PharmacistProfileError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is PharmacistProfileLoaded &&
              state.pharmacistProfile.isProfileComplete) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile completed successfully')),
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
              state is PharmacistProfileUpdating) {
            final profile = (state is PharmacistProfileLoaded)
                ? state.pharmacistProfile
                : (state as PharmacistProfileUpdating).pharmacistProfile;
            return _buildForm(profile);
          } else {
            return const Center(child: Text('Failed to load profile'));
          }
        },
      ),
    );
  }

  Widget _buildForm(PharmacistProfile profile) {
    _populateFields(profile);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileImage(context, profile.profileImageUrl),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _nameController,
              label: 'Name',
              validator: _validateName,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _emailController,
              label: 'Email',
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _ageController,
              label: 'Age',
              keyboardType: TextInputType.number,
              validator: _validateAge,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _phoneController,
              label: 'Phone',
              keyboardType: TextInputType.phone,
              validator: _validatePhoneNumber,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _houseNameController,
              label: 'House Name',
              validator: _validateHouseName,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _streetController,
              label: 'Street',
              validator: _validateStreet,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: _cityController,
                    label: 'City',
                    validator: _validateCity,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomTextFormField(
                    controller: _stateController,
                    label: 'State',
                    validator: _validateState,
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
                    validator: _validatePostalCode,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomTextFormField(
                    controller: _licenseNumberController,
                    label: 'License Number',
                    validator: _validateLicenseNumber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Complete Profile',
              onPressed: () => _completeProfile(profile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, String? imageUrl) {
    return GestureDetector(
      onTap: _pickImage,
      child: BlocBuilder<PharmacistProfileBloc, PharmacistProfileState>(
        builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: imageUrl != null
                    ? CachedNetworkImageProvider(imageUrl) as ImageProvider
                    : null,
                child: imageUrl == null
                    ? const Icon(Icons.add_a_photo, size: 40)
                    : null,
              ),
              if (state is PharmacistProfileUpdating)
                const CircularProgressIndicator(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        context.read<PharmacistProfileBloc>().add(
              UploadPharmacistProfileImage(
                  widget.pharmacistId, File(image.path)),
            );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _populateFields(PharmacistProfile profile) {
    _nameController.text = profile.name ?? '';
    _emailController.text = profile.email ?? '';
    _ageController.text = profile.age ?? '';
    _phoneController.text = profile.phone ?? '';
    _houseNameController.text = profile.houseName ?? '';
    _streetController.text = profile.street ?? '';
    _cityController.text = profile.city ?? '';
    _stateController.text = profile.state ?? '';
    _postalCodeController.text = profile.postalCode ?? '';
    _licenseNumberController.text = profile.licenseNumber ?? '';
  }

  void _completeProfile(PharmacistProfile profile) {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = profile.copyWith(
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    int? age = int.tryParse(value);
    if (age == null || age < 18 || age > 100) {
      return 'Enter a valid age between 18 and 100';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[6789]\d{9}$').hasMatch(value)) {
      return 'Enter a valid 10-digit Indian phone number';
    }
    return null;
  }

  String? _validateHouseName(String? value) {
    if (value == null || value.isEmpty) {
      return 'House name is required';
    }
    return null;
  }

  String? _validateStreet(String? value) {
    if (value == null || value.isEmpty) {
      return 'Street is required';
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }
    return null;
  }

  String? _validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'State is required';
    }
    return null;
  }

  String? _validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Enter a valid 6-digit postal code';
    }
    return null;
  }

  String? _validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'License number is required';
    }
    // Add specific validation for license number format if needed
    return null;
  }
}
