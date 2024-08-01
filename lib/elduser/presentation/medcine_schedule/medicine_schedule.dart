import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/elduser/blocs/medicine/medicine_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ScheduleScreenState createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Medicine Schedule',
          style: AppFonts.headline1,
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateChanged: (date) {
              setState(() {
                selectedDate = date;
              });
              context.read<MedicineBloc>().add(FetchMedicinesForDate(date));
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Scheduled Medicines",
          style: AppFonts.headline3Dark,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: BlocBuilder<MedicineBloc, MedicineState>(
            builder: (context, state) {
              if (state is MedicineLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MedicinesLoaded) {
                if (state.medicines.isEmpty) {
                  return const Center(
                      child: Text('No medicines scheduled for this date'));
                }
                return ListView.builder(
                  itemCount: state.medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = state.medicines[index];
                    return ListTile(
                      leading:
                          const Icon(Icons.medication, color: kPrimaryColor),
                      title: Text(medicine.name),
                      subtitle:
                          Text('${medicine.dosage} - ${medicine.startDate}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // TODO: Implement edit functionality
                        },
                      ),
                    );
                  },
                );
              } else if (state is MedicineError) {
                return Center(child: Text('Error: ${state.message}'));
              } else {
                return const Center(child: Text('Unknown state'));
              }
            },
          ),
        ),
      ],
    );
  }
}
