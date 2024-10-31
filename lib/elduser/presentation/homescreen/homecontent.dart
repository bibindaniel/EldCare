import 'dart:io';

import 'package:eldcare/elduser/blocs/medicine/medicine_bloc.dart';
import 'package:eldcare/elduser/presentation/homescreen/notification_service.dart';
import 'package:eldcare/elduser/presentation/medcine_schedule/add_schedule.dart';
import 'package:eldcare/elduser/widgets/medicine_card.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eldcare/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/font.dart';
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
  final picker = ImagePicker();
  File? _pillCoverImage;
  String? _scannedText;
  Map<String, dynamic>? _medicineInfo;
  final TextEditingController _manualSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    notificationService = NotificationService();
    _initializeNotificationService();
  }

  Future<void> _initializeNotificationService() async {
    await notificationService.init();
  }

  Future<void> _capturePillCover() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _pillCoverImage = File(image.path);
        _scannedText = null;
        _medicineInfo = null;
      });
      await _performOCR();
    }
  }

  Future<void> _performOCR() async {
    if (_pillCoverImage == null) return;

    final inputImage = InputImage.fromFilePath(_pillCoverImage!.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    setState(() {
      _scannedText = recognizedText.text;
    });

    await textRecognizer.close();
    await _queryMedicineDatabase(_scannedText!);
  }

  String extractRelevantInfo(String ocrText) {
    // List of known common words that might appear on pill strips but are irrelevant
    List<String> irrelevantWords = [
      'USP',
      'tablet',
      'capsule',
      'mg',
      'lot',
      'exp',
      'use',
      'before',
      'dose',
      'expiry',
      'manufactured',
      'by',
      'company',
      'batch',
      'number',
      'strip'
    ];

    // Split the OCR result into individual words
    List<String> words = ocrText.split(RegExp(r'\s+'));

    // Filter out common irrelevant words and words with numbers (like batch numbers, dosage, etc.)
    words.removeWhere((word) =>
        irrelevantWords.contains(word.toLowerCase()) ||
        RegExp(r'[0-9]').hasMatch(word));

    // Join remaining words back to a clean string
    String filteredText = words.join(' ');

    // Further refine the query if needed (e.g., length checks, etc.)
    return filteredText.trim();
  }

  Future<void> _queryMedicineDatabase(String ocrText) async {
    final apiKey = dotenv.env['OPEN_FDA_API_KEY'];

    if (apiKey == null) {
      setState(() {
        _medicineInfo = {'error': 'API key is missing'};
      });
      return;
    }

    // Step 1: Extract relevant information from the OCR text
    String query = extractRelevantInfo(ocrText);

    if (query.isEmpty) {
      setState(() {
        _medicineInfo = {
          'error': 'No valid medicine name found on the pill strip.'
        };
      });
      return;
    }

    // Step 2: Query the OpenFDA API with the filtered query
    final response = await http.get(Uri.parse(
        'https://api.fda.gov/drug/label.json?search=openfda.brand_name:"${Uri.encodeComponent(query)}"&limit=1&api_key=$apiKey'));

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Step 3: Handle the API response
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final openfda = result['openfda'] ?? {};

          setState(() {
            _medicineInfo = {
              'name': openfda['brand_name']?[0] ?? 'Unknown',
              'generic_name': openfda['generic_name']?[0] ?? 'Unknown',
              'manufacturer_name':
                  openfda['manufacturer_name']?[0] ?? 'Unknown',
              'purpose': result['purpose']?[0] ?? 'Unknown',
              'warnings': result['warnings']?[0] ?? 'Unknown',
            };
          });
        } else {
          setState(() {
            _medicineInfo = {'error': 'No information found for this medicine'};
          });
        }
      } catch (e) {
        setState(() {
          _medicineInfo = {'error': 'Failed to parse the medicine information'};
        });
        print('Error parsing response: $e');
      }
    } else {
      setState(() {
        _medicineInfo = {
          'error':
              'Failed to fetch medicine information. Status code: ${response.statusCode}'
        };
      });
    }
  }

  Widget _buildPillCoverScanSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pill Cover Scan', style: AppFonts.headline3),
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
            onPressed: _capturePillCover,
            child:
                const Text('Scan Pill Cover', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 16),
          const Text('Or search manually:', style: AppFonts.headline4),
          const SizedBox(height: 8),
          TextField(
            controller: _manualSearchController,
            decoration: InputDecoration(
              hintText: 'Enter medicine name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: kWhiteColor,
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              final manualSearchText = _manualSearchController.text.trim();
              if (manualSearchText.isNotEmpty) {
                _queryMedicineDatabase(manualSearchText);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a medicine name'),
                  ),
                );
              }
            },
            child: const Text('Search', style: TextStyle(fontSize: 16)),
          ),
          if (_pillCoverImage != null)
            Image.file(_pillCoverImage!, height: 200, width: 200),
          if (_scannedText != null) Text('Scanned Text: $_scannedText'),
          if (_medicineInfo != null) _buildMedicineInfo(),
        ],
      ),
    );
  }

  Widget _buildMedicineInfo() {
    if (_medicineInfo!.containsKey('error')) {
      return Text(_medicineInfo!['error'], style: TextStyle(color: Colors.red));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Medicine Information:', style: AppFonts.headline4),
        Text('Name: ${_medicineInfo!['name']}'),
        Text('Generic Name: ${_medicineInfo!['generic_name']}'),
        Text('Manufacturer: ${_medicineInfo!['manufacturer_name']}'),
        Text('Purpose: ${_medicineInfo!['purpose']}'),
        Text('Warnings: ${_medicineInfo!['warnings']}'),
      ],
    );
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
            _buildPillCoverScanSection(),
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
}
