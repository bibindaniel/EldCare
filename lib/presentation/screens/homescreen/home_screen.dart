import 'package:eldcare/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/presentation/blocs/auth/auth_event.dart';
import 'package:eldcare/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/presentation/screens/login%20&%20singup/rolesection/roleselection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is RoleSelectionNeeded) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RoleSelectionScreen(userId: state.user.uid),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutEvent());
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center the content vertically
            children: [
              SizedBox(
                height: 200, // Set a fixed height
                width: 200, // Set a fixed width
                child: Lottie.asset(
                  'assets/animations/test.json',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(
                  height:
                      20), // Add some space between the animation and the text
              const Text(
                'Welcome to EldCare',
                style: AppFonts.headline1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
