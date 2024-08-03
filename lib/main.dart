import 'package:eldcare/core/theme/routes/myroutes.dart';
import 'package:eldcare/elduser/blocs/medicine/medicine_bloc.dart';
import 'package:eldcare/elduser/blocs/navigation/navigation_bloc.dart';
import 'package:eldcare/elduser/blocs/userprofile/userprofile_bloc.dart';
import 'package:eldcare/elduser/presentation/homescreen/notification_service.dart';
import 'package:eldcare/elduser/repository/userprofile_repository.dart';
import 'package:eldcare/firebase_options.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_event.dart';
import 'package:eldcare/auth/presentation/screens/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Workmanager().initialize(callbackDispatcher);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'scheduleMedicineNotification':
        final id = inputData!['id'];
        final title = inputData['title'];
        final body = inputData['body'];
        final hour = inputData['hour'];
        final minute = inputData['minute'];

        final scheduledDate = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          hour,
          minute,
        );

        await NotificationService().showNotification(
          id,
          title,
          body,
          scheduledDate,
        );
        break;
    }
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => AuthBloc()..add(CheckLoginStatus())),
          BlocProvider(create: (context) => AuthBloc()),
          BlocProvider(
              create: (context) => UserProfileBloc(UserProfileRepository())),
          BlocProvider(create: (context) => NavigationBloc()),
          BlocProvider(
              create: (context) => MedicineBloc()
                ..add(FetchMedicinesForDate(DateTime.now()))
                ..add(FetchCompletedMedicines())),
        ],
        child: const MaterialApp(
          onGenerateRoute: Myroutes.generateRoute,
          initialRoute: Myroutes.splash,
          home: Splashscreen(),
          debugShowCheckedModeBanner: false,
        ));
  }
}
