import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/auth/presentation/widgets/textboxwidget.dart';
import 'package:eldcare/auth/presentation/widgets/button_widget.dart';
import 'package:eldcare/doctor/blocs/registration/doctor_registration_bloc.dart';
import 'package:eldcare/doctor/blocs/registration/doctor_registration_event.dart';
import 'package:eldcare/doctor/blocs/registration/doctor_registration_state.dart';
import 'package:eldcare/doctor/presentation/screens/auth/doctor_waiting_approval_screen.dart';

class DoctorRegistrationScreen extends StatefulWidget {
  final String userId;
  const DoctorRegistrationScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  State<DoctorRegistrationScreen> createState() =>
      _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Details Controllers
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();

  // Professional Details Controllers
  final _registrationNumberController = TextEditingController();
  final _medicalCouncilController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();

  // Current Practice Controllers
  final _hospitalNameController = TextEditingController();
  final _hospitalAddressController = TextEditingController();
  final _workContactController = TextEditingController();
  final _workEmailController = TextEditingController();

  final Map<String, File> _documentFiles = {};
  final Map<String, String> _documentNames = {};

  Future<void> _pickDocument(String documentType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final String fileName = file.name.toLowerCase();

        // Check if file extension is supported
        if (!fileName.endsWith('.jpg') &&
            !fileName.endsWith('.jpeg') &&
            !fileName.endsWith('.png') &&
            !fileName.endsWith('.pdf')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a JPG, JPEG, PNG, or PDF file'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final File pickedFile = File(result.files.single.path!);

        // Check file size (optional, adjust max size as needed)
        final fileSize = await pickedFile.length();
        if (fileSize > 5 * 1024 * 1024) {
          // 5MB limit
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File size should be less than 5MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _documentFiles[documentType] = pickedFile;
          _documentNames[documentType] = result.files.single.name;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully uploaded ${result.files.single.name}'),
            backgroundColor: Colors.green,
          ),
        );

        context.read<DoctorRegistrationBloc>().add(
              UpdateDocumentFile(
                documentType: documentType,
                file: pickedFile,
              ),
            );
      }
    } catch (e) {
      print('Error picking document: $e'); // For debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking document: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildUploadButton(String label, String documentType) {
    final hasFile = _documentFiles.containsKey(documentType);
    final fileName = _documentNames[documentType];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => _pickDocument(documentType),
          icon: Icon(hasFile ? Icons.check_circle : Icons.upload_file),
          label: Text(hasFile ? 'Change $label' : 'Upload $label'),
          style: OutlinedButton.styleFrom(
            foregroundColor: hasFile ? Colors.green : kPrimaryColor,
            side: BorderSide(color: hasFile ? Colors.green : kPrimaryColor),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
        if (hasFile) ...[
          const SizedBox(height: 4),
          Text(
            fileName!,
            style: AppFonts.bodyText2.copyWith(color: Colors.green),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_documentFiles.length < 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload all required documents')),
        );
        return;
      }

      context.read<DoctorRegistrationBloc>().add(
            SubmitDoctorRegistration(
              userId: widget.userId,
              fullName: _fullNameController.text,
              mobileNumber: _mobileController.text,
              address: _addressController.text,
              registrationNumber: _registrationNumberController.text,
              medicalCouncil: _medicalCouncilController.text,
              qualification: _qualificationController.text,
              specialization: _specializationController.text,
              experience: int.parse(_experienceController.text),
              hospitalName: _hospitalNameController.text,
              hospitalAddress: _hospitalAddressController.text,
              workContact: _workContactController.text,
              workEmail: _workEmailController.text,
              documents: _documentFiles,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Registration',
            style: AppFonts.headline2.copyWith(color: Colors.white)),
        backgroundColor: kPrimaryColor,
      ),
      body: BlocConsumer<DoctorRegistrationBloc, DoctorRegistrationState>(
        listener: (context, state) {
          if (state is DoctorRegistrationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          } else if (state is DoctorRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const DoctorWaitingApprovalScreen(),
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionTitle('Personal Details'),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _fullNameController,
                        label: 'Full Name (as per Medical Registration)',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter your full name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _mobileController,
                        label: 'Personal Mobile Number',
                        keyboardType: TextInputType.phone,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter your mobile number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _addressController,
                        label: 'Residential Address',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter your address'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Professional Details'),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _registrationNumberController,
                        label: 'Medical Registration Number',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter your registration number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _medicalCouncilController,
                        label: 'State Medical Council Name',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter medical council name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _qualificationController,
                        label: 'Primary Medical Qualification',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter your qualification'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _specializationController,
                        label: 'Specialization',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter your specialization'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _experienceController,
                        label: 'Years of Experience',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter years of experience';
                          }
                          if (int.tryParse(value!) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Current Practice Details'),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _hospitalNameController,
                        label: 'Current Hospital/Clinic Name',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter hospital/clinic name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _hospitalAddressController,
                        label: 'Hospital/Clinic Address',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter hospital/clinic address'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _workContactController,
                        label: 'Work Contact Number',
                        keyboardType: TextInputType.phone,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter work contact number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _workEmailController,
                        label: 'Work Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter work email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value!)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Document Upload'),
                      const SizedBox(height: 16),
                      _buildUploadButton(
                        'Medical Registration Certificate',
                        'registration_certificate',
                      ),
                      const SizedBox(height: 12),
                      _buildUploadButton(
                        'Medical Degree Certificate',
                        'degree_certificate',
                      ),
                      const SizedBox(height: 12),
                      _buildUploadButton(
                        'Government ID Proof',
                        'id_proof',
                      ),
                      const SizedBox(height: 12),
                      _buildUploadButton(
                        'Professional Photo',
                        'photo',
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: 'Submit Registration',
                        onPressed: state is DoctorRegistrationLoading
                            ? null
                            : _submitForm,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              if (state is DoctorRegistrationLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: AppFonts.headline3.copyWith(
          color: kPrimaryColor,
          fontSize: 18,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _registrationNumberController.dispose();
    _medicalCouncilController.dispose();
    _qualificationController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _hospitalNameController.dispose();
    _hospitalAddressController.dispose();
    _workContactController.dispose();
    _workEmailController.dispose();
    super.dispose();
  }
}
