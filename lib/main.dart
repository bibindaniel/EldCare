import 'package:eldcare/core/theme/routes/myroutes.dart';
import 'package:eldcare/firebase_options.dart';
import 'package:eldcare/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/presentation/blocs/auth/auth_event.dart';
import 'package:eldcare/presentation/screens/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => AuthBloc()..add(CheckLoginStatus())),
        ],
        child: const MaterialApp(
          onGenerateRoute: Myroutes.generateRoute,
          initialRoute: Myroutes.splash,
          home: Splashscreen(),
          debugShowCheckedModeBanner: false,
        ));
  }
}
