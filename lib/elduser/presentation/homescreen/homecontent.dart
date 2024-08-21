import 'package:eldcare/elduser/blocs/medicine/medicine_bloc.dart';
import 'package:eldcare/elduser/presentation/homescreen/notification_service.dart';
import 'package:eldcare/elduser/presentation/medcine_schedule/add_schedule.dart';
import 'package:eldcare/elduser/widgets/medicine_card.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/font.dart';
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

  @override
  void initState() {
    super.initState();
    notificationService = NotificationService();
    _initializeNotificationService();
  }

  Future<void> _initializeNotificationService() async {
    await notificationService.init();
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
