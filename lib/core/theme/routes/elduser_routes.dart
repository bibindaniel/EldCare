import 'package:eldcare/elduser/presentation/medcine_schedule/add_schedule.dart';
import 'package:eldcare/elduser/presentation/medcine_schedule/medicine_schedule.dart';
import 'package:flutter/material.dart';

class EldUserRoutes {
  static const String addSchedule = '/addSchedule';
  static const String scheduleMedicine = '/schedule_medicine';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case addSchedule:
        return MaterialPageRoute(builder: (context) => const AddMedicinePage());
      case scheduleMedicine:
        return MaterialPageRoute(
          builder: (context) => const ScheduleScreen(),
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
