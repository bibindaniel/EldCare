import 'package:eldcare/elduser/blocs/presentation/medcine_schedule/add_schedule.dart';
import 'package:flutter/material.dart';

class EldUserRoutes {
  static const String addschedule = '/addSchedule';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case addschedule:
        return MaterialPageRoute(builder: (context) => AddMedicinePage());

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
