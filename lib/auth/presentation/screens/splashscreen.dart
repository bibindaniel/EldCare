import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_event.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/auth/presentation/screens/login%20&%20singup/rolesection/roleselection_screen.dart';
import 'package:eldcare/auth/presentation/screens/login%20&%20singup/rolesection/user_redirection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/auth/presentation/screens/login%20&%20singup/login_screen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  SplashscreenState createState() => SplashscreenState();
}

class SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckLoginStatus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Navigate to HomeScreen if the user is authenticated
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserRedirection()),
            );
          } else if (state is Unauthenticated) {
            // Navigate to LoginScreen if the user is not authenticated
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          } else if (state is RoleSelectionNeeded) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    RoleSelectionScreen(userId: state.user.uid),
              ),
            );
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/icons/eldcare.png',
                    width: 300, height: 300, color: Colors.white),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "EldCare",
                  style: AppFonts.headline1Light,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
