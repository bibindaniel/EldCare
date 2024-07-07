import 'package:flutter/material.dart';
import 'package:eldcare/presentation/screens/homescreen/home_screen.dart';
import 'package:eldcare/presentation/screens/login%20&%20singup/login_screen.dart';
import 'package:eldcare/presentation/screens/login%20&%20singup/register_screen.dart';
import 'package:eldcare/presentation/screens/splashscreen.dart';

class Myroutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (context) => const Splashscreen());
      case login:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case register:
        return MaterialPageRoute(builder: (context) => RegistrationScreen());
      case home:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
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
