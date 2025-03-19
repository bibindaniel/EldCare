import 'package:eldcare/doctor/repositories/doctor_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/doctor/blocs/profile/doctor_profile_bloc.dart';
import 'package:eldcare/doctor/blocs/profile/doctor_profile_event.dart';
import 'package:eldcare/doctor/blocs/profile/doctor_profile_state.dart';
import 'package:eldcare/doctor/models/doctor.dart';
import 'package:eldcare/auth/presentation/widgets/textboxwidget.dart';
import 'package:eldcare/auth/presentation/widgets/button_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final Doctor doctor;

  const EditProfileScreen({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _addressController;
  late final TextEditingController _specializationController;
  late final TextEditingController _hospitalNameController;
  late final TextEditingController _hospitalAddressController;
  late final TextEditingController _workContactController;
  late final TextEditingController _workEmailController;
  late final TextEditingController _consultationFeeController;
  late int _consultationDuration;
  late bool _emergencyAvailable;
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.doctor.fullName);
    _mobileController = TextEditingController(text: widget.doctor.mobileNumber);
    _addressController = TextEditingController(text: widget.doctor.address);
    _specializationController =
        TextEditingController(text: widget.doctor.specialization);
    _hospitalNameController =
        TextEditingController(text: widget.doctor.hospitalName);
    _hospitalAddressController =
        TextEditingController(text: widget.doctor.hospitalAddress);
    _workContactController =
        TextEditingController(text: widget.doctor.workContact);
    _workEmailController = TextEditingController(text: widget.doctor.workEmail);

    _consultationFeeController = TextEditingController(
        text: (widget.doctor.consultationFee ?? 100).toString());
    _consultationDuration = widget.doctor.consultationDuration ?? 30;
    _emergencyAvailable = widget.doctor.emergencyAvailable ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorProfileBloc(
        doctorRepository: DoctorRepository(),
      ),
      child: Builder(builder: (builderContext) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile', style: AppFonts.headline2),
            backgroundColor: kPrimaryColor,
          ),
          body: BlocListener<DoctorProfileBloc, DoctorProfileState>(
            listener: (context, state) {
              if (state is DoctorProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is DoctorProfileLoaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );

                Future.delayed(const Duration(milliseconds: 150), () {
                  Navigator.pop(context);
                });
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: widget.doctor.profileImageUrl != null
                              ? NetworkImage(widget.doctor.profileImageUrl!)
                              : null,
                          child: widget.doctor.profileImageUrl == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickProfileImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextFormField(
                    controller: _fullNameController,
                    label: 'Full Name',
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _mobileController,
                    label: 'Mobile Number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _addressController,
                    label: 'Address',
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _specializationController,
                    label: 'Specialization',
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _hospitalNameController,
                    label: 'Hospital Name',
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _hospitalAddressController,
                    label: 'Hospital Address',
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _workContactController,
                    label: 'Work Contact',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _workEmailController,
                    label: 'Work Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Consultation Settings',
                    style: AppFonts.headline4,
                  ),
                  const SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _consultationFeeController,
                    label: 'Consultation Fee (₹)',
                    keyboardType: TextInputType.number,
                    // prefixIcon: const Icon(Icons.attach_money),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Consultation Duration',
                          style: AppFonts.bodyText1),
                      const SizedBox(height: 8),
                      Row(
                        children: [15, 30, 45, 60].map((duration) {
                          return Expanded(
                            child: RadioListTile<int>(
                              title: Text('$duration min'),
                              value: duration,
                              groupValue: _consultationDuration,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _consultationDuration = value;
                                  });
                                }
                              },
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Emergency Availability',
                        style: AppFonts.bodyText1),
                    value: _emergencyAvailable,
                    onChanged: (value) {
                      setState(() {
                        _emergencyAvailable = value;
                      });
                    },
                    secondary:
                        const Icon(Icons.emergency, color: kPrimaryColor),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Save Changes',
                    onPressed: () => _saveProfileWithContext(builderContext),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _specializationController.dispose();
    _hospitalNameController.dispose();
    _hospitalAddressController.dispose();
    _workContactController.dispose();
    _workEmailController.dispose();
    _consultationFeeController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _profileImageFile = File(image.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image selected. Save to update.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveProfileWithContext(BuildContext context) {
    final int? consultationFee = int.tryParse(_consultationFeeController.text);

    final Map<String, dynamic> updates = {
      'fullName': _fullNameController.text,
      'mobileNumber': _mobileController.text,
      'address': _addressController.text,
      'specialization': _specializationController.text,
      'hospitalName': _hospitalNameController.text,
      'hospitalAddress': _hospitalAddressController.text,
      'workContact': _workContactController.text,
      'workEmail': _workEmailController.text,
      'consultationFee': consultationFee,
      'consultationDuration': _consultationDuration,
      'emergencyAvailable': _emergencyAvailable,
    };

    context.read<DoctorProfileBloc>().add(
          UpdateDoctorProfile(
            doctorId: widget.doctor.userId,
            updates: updates,
            profileImageFile: _profileImageFile,
          ),
        );
  }
}
