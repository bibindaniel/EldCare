// lib/pages/schedule_medicine_page.dart
import 'package:eldcare/elduser/blocs/medicine/medicine_bloc.dart';
import 'package:eldcare/elduser/models/medicine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScheduleMedicinePage extends StatefulWidget {
  final Medicine medicine;

  ScheduleMedicinePage({Key? key, required this.medicine}) : super(key: key);

  @override
  _ScheduleMedicinePageState createState() => _ScheduleMedicinePageState();
}

class _ScheduleMedicinePageState extends State<ScheduleMedicinePage> {
  int _frequency = 1;
  List<TimeOfDay> _scheduleTimes = [TimeOfDay.now()];
  bool _isBeforeFood = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicineBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Schedule ${widget.medicine.name}'),
        ),
        body: BlocBuilder<MedicineBloc, MedicineState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How many times a day?'),
                  DropdownButton<int>(
                    value: _frequency,
                    items: [1, 2, 3, 4].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value time(s)'),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _frequency = newValue!;
                        _scheduleTimes = List.generate(
                            _frequency, (index) => TimeOfDay.now());
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Text('Set times:'),
                  ..._scheduleTimes.asMap().entries.map((entry) {
                    int idx = entry.key;
                    TimeOfDay time = entry.value;
                    return ListTile(
                      title: Text('Dose ${idx + 1}: ${time.format(context)}'),
                      trailing: IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (picked != null) {
                            setState(() {
                              _scheduleTimes[idx] = picked;
                            });
                          }
                        },
                      ),
                    );
                  }),
                  SizedBox(height: 20),
                  Text('Take medicine:'),
                  RadioListTile(
                    title: Text('Before food'),
                    value: true,
                    groupValue: _isBeforeFood,
                    onChanged: (bool? value) {
                      setState(() {
                        _isBeforeFood = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('After food'),
                    value: false,
                    groupValue: _isBeforeFood,
                    onChanged: (bool? value) {
                      setState(() {
                        _isBeforeFood = value!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text('Save Schedule'),
                    onPressed: () {
                      List<DateTime> scheduleTimes = _scheduleTimes.map((time) {
                        final now = DateTime.now();
                        return DateTime(now.year, now.month, now.day, time.hour,
                            time.minute);
                      }).toList();
                      context.read<MedicineBloc>().add(
                            UpdateMedicineSchedule(
                                widget.medicine, scheduleTimes, _isBeforeFood),
                          );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
