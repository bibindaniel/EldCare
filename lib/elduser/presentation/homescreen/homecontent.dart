import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:eldcare/elduser/blocs/medicine/medicine_bloc.dart';
import 'package:eldcare/elduser/presentation/homescreen/notification_service.dart';
import 'package:eldcare/elduser/presentation/medcine_schedule/add_schedule.dart';
import 'package:eldcare/elduser/widgets/medicine_card.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  DateTime selectedDate = DateTime.now();
  late NotificationService notificationService;
  File? _image;
  final picker = ImagePicker();
  Map<String, dynamic>? _detectionResults;
  bool _isAnalyzing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    notificationService = NotificationService();
    _initializeNotificationService();
  }

  Future<void> _initializeNotificationService() async {
    await notificationService.init();
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _detectionResults = null; // Reset detection results
          _errorMessage = null; // Reset error message
        });
        await _processImage();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error capturing image: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: kPrimaryColor,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTopSection(),
            const SizedBox(height: 30),
            _buildBottomSection(),
            const SizedBox(height: 30),
            _buildPillDetectionSection()
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text('Create a New Schedule', style: AppFonts.headline3Light),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: kPrimaryColor,
                backgroundColor: kWhiteColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AddMedicinePage()));
              },
              child: const Text('Add', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        Lottie.asset('assets/animations/medical.json', width: 100, height: 100),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildDateSelector(),
          const SizedBox(height: 20),
          _buildMedicineSection(),
          const SizedBox(height: 12),
          _buildUpcomingEvents(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 30,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
              context.read<MedicineBloc>().add(FetchMedicinesForDate(date));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: date.day == selectedDate.day &&
                        date.month == selectedDate.month &&
                        date.year == selectedDate.year
                    ? kPrimaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      color: date.day == selectedDate.day &&
                              date.month == selectedDate.month &&
                              date.year == selectedDate.year
                          ? kWhiteColor
                          : kBlackColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      color: date.day == selectedDate.day &&
                              date.month == selectedDate.month &&
                              date.year == selectedDate.year
                          ? kWhiteColor
                          : kBlackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicineSection() {
    return Column(
      children: [
        const Text("To Take", style: AppFonts.headline3),
        const SizedBox(height: 20),
        BlocBuilder<MedicineBloc, MedicineState>(
          builder: (context, state) {
            if (state is MedicineLoading) {
              return const CircularProgressIndicator();
            } else if (state is MedicinesLoaded) {
              if (state.medicines.isEmpty) {
                return const Text('No medicines scheduled for this date');
              }
              return SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = state.medicines[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: MedicineCard(medicine: medicine),
                    );
                  },
                ),
              );
            } else if (state is MedicineError) {
              return Text('Error: ${state.message}');
            } else {
              return const Text('Unknown state');
            }
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingEvents() {
    return const Column(
      children: [
        Text("Upcoming Events", style: AppFonts.headline3),
        SizedBox(height: 10),
        Card(
          color: kPrimaryColor,
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.medical_services,
                      size: 36, color: kThridColor),
                  title: Text('Dr. Smith Appointment',
                      style: TextStyle(fontSize: 18, color: kWhiteColor)),
                  subtitle: Text('July 16, 10:00 AM',
                      style: TextStyle(fontSize: 16, color: kWhiteColor)),
                ),
                ListTile(
                  leading: Icon(Icons.local_shipping,
                      size: 36, color: kSecondaryColor),
                  title: Text('Medication Delivery',
                      style: TextStyle(fontSize: 18, color: kWhiteColor)),
                  subtitle: Text('July 15, 2:00 PM',
                      style: TextStyle(fontSize: 16, color: kWhiteColor)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _detectPill(File imageFile) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    // Simulate detection results
    final random = Random();
    final pillShapes = ['Round', 'Oval', 'Capsule'];
    final pillColors = ['White', 'Red', 'Blue', 'Yellow'];

    return {
      'shape': pillShapes[random.nextInt(pillShapes.length)],
      'color': pillColors[random.nextInt(pillColors.length)],
      'text': 'ABC${random.nextInt(100)}',
    };
  }

  Widget _buildPillDetectionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pill Detection', style: AppFonts.headline3),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: kWhiteColor,
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () => _showImageSourceActionSheet(context),
            child: const Text('Capture Pill Image',
                style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: _buildImageContent(),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (_image != null && _detectionResults == null && !_isAnalyzing)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: _analyzePill,
                child: const Text('Analyze Pill'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: kWhiteColor,
                  backgroundColor: kPrimaryColor,
                ),
              ),
            ),
          if (_detectionResults != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detection Results:', style: AppFonts.headline4),
                  Text('Shape: ${_detectionResults!['shape']}'),
                  Text('Color: ${_detectionResults!['color']}'),
                  Text('Text: ${_detectionResults!['text']}'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _provideFeedback(true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text('Correct'),
                      ),
                      ElevatedButton(
                        onPressed: () => _provideFeedback(false),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Incorrect'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _provideFeedback(bool isCorrect) {
    // In a real app, you would send this feedback to your server
    // to improve the model. For now, we'll just show a thank you message.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect
            ? 'Thank you for confirming!'
            : 'Thank you for your feedback. We\'ll improve our detection.'),
      ),
    );

    // Reset the UI after feedback
    setState(() {
      _detectionResults = null;
      _image = null;
    });
  }

  Widget _buildImageContent() {
    if (_image == null) {
      return const Center(child: Text('Captured image will appear here'));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(_image!, fit: BoxFit.cover),
        ),
        if (_isAnalyzing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: kWhiteColor),
            ),
          ),
      ],
    );
  }

  Future<void> _analyzePill() async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final results = await _detectPill(_image!);
      setState(() {
        _detectionResults = results;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error analyzing pill: $e';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _processImage() async {
    if (_image == null) return;

    try {
      // Read the image file
      Uint8List imageBytes = await _image!.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image != null) {
        // Resize the image to a standard size
        img.Image resizedImage = img.copyResize(image, width: 300);

        // Convert the image to grayscale
        img.Image grayscaleImage = img.grayscale(resizedImage);

        // Apply contrast enhancement
        img.Image contrastedImage = img.contrast(grayscaleImage, contrast: 50);

        // Apply edge detection (Sobel filter)
        img.Image edgeImage = img.sobel(contrastedImage);

        // Encode the processed image back to PNG
        List<int> processedBytes = img.encodePng(edgeImage);

        // Save the processed image
        await _image!.writeAsBytes(processedBytes);

        setState(() {
          // Update the UI to reflect the processed image
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error processing image: $e';
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
