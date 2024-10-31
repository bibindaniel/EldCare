import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eldcare/elduser/models/user_profile.dart';
import 'package:eldcare/elduser/blocs/userprofile/userprofile_bloc.dart';
import 'package:eldcare/auth/presentation/widgets/textboxwidget.dart';
import 'package:eldcare/auth/presentation/widgets/button_widget.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';

class ProfileUpdatePage extends StatefulWidget {
  final String userId;

  const ProfileUpdatePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileUpdatePageState createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
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
  String _selectedBloodType = 'A+';

  @override
  void initState() {
    super.initState();
    context.read<UserProfileBloc>().add(LoadUserProfile(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile',
            style: AppFonts.headline2.copyWith(color: Colors.white)),
        backgroundColor: kPrimaryColor,
      ),
      body: BlocConsumer<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is UserProfileLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: kSuccessColor,
              ),
            );
          }
        },
        builder: (context, state) {
          print('Current state: $state'); // Debug print
          if (state is UserProfileLoading || state is UserProfileUpdating) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserProfileLoaded) {
            return _buildForm(state.userProfile);
          } else if (state is UserProfileError) {
            return Center(child: Text('Error: ${state.error}'));
          } else {
            return Center(
                child: Text(
                    'Unexpected state: ${state.runtimeType}. Please try again.'));
          }
        },
      ),
    );
  }

  void _populateFields(UserProfile userProfile) {
    _nameController.text = userProfile.name ?? '';
    _emailController.text = userProfile.email ?? '';
    _ageController.text = userProfile.age ?? '';
    _phoneController.text = userProfile.phone ?? '';
    _houseNameController.text = userProfile.houseName ?? '';
    _streetController.text = userProfile.street ?? '';
    _cityController.text = userProfile.city ?? '';
    _stateController.text = userProfile.state ?? '';
    _postalCodeController.text = userProfile.postalCode ?? '';
    _selectedBloodType = userProfile.bloodType ?? 'A+';
  }

  Widget _buildForm(UserProfile userProfile) {
    _populateFields(userProfile);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileImage(context, userProfile.profileImageUrl),
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
                  child: _buildBloodTypeDropdown(userProfile.bloodType),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Update Profile',
              onPressed: () => _updateProfile(userProfile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, String? imageUrl) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? const Icon(Icons.add_a_photo, size: 40)
                : null,
          ),
          if (context.watch<UserProfileBloc>().state is UserProfileUpdating)
            const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildBloodTypeDropdown(String? currentBloodType) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Blood Type',
        border: OutlineInputBorder(),
      ),
      value: _selectedBloodType,
      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
          .map((String bloodType) {
        return DropdownMenuItem<String>(
          value: bloodType,
          child: Text(bloodType),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedBloodType = newValue;
          });
        }
      },
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        context
            .read<UserProfileBloc>()
            .add(UploadProfileImage(widget.userId, File(image.path)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _updateProfile(UserProfile userProfile) {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = userProfile.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        age: _ageController.text,
        phone: _phoneController.text,
        houseName: _houseNameController.text,
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        postalCode: _postalCodeController.text,
        bloodType: _selectedBloodType, // Include the updated blood type
      );
      context.read<UserProfileBloc>().add(UpdateUserProfile(updatedProfile));
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

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    int? age = int.tryParse(value);
    if (age == null) {
      return 'Age must be a valid number';
    }
    if (age < 10 || age > 120) {
      return 'Age must be between 10 and 120';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[789]\d{9}$').hasMatch(value)) {
      return 'Invalid Indian phone number';
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

  String? validateStreet(String? value) {
    if (value == null || value.isEmpty) {
      return 'Street is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return 'Invalid street';
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

  String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'State is required';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Invalid state';
    }
    return null;
  }

  String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }
    if (value.length != 6 || int.tryParse(value) == null) {
      return 'Postal code must be a 6-digit number';
    }
    return null;
  }
}
