import 'package:eldcare/elduser/models/medicine.dart';
import 'package:eldcare/elduser/presentation/medcine_schedule/add_schedule.dart';
import 'package:eldcare/elduser/presentation/medcine_schedule/schedule_medicine.dart';
import 'package:flutter/material.dart';

class EldUserRoutes {
  static const String addSchedule = '/addSchedule';
  static const String scheduleMedicine = '/schedule_medicine';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case addSchedule:
        return MaterialPageRoute(builder: (context) => const AddMedicinePage());
      case scheduleMedicine:
        final medicine = settings.arguments as Medicine;
        print("entered in medicine");
        return MaterialPageRoute(
          builder: (context) => ScheduleMedicinePage(medicine: medicine),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('404: Page not found'),
            ),
          ),
        );
    }
  }
}
