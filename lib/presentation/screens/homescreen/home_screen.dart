import 'package:eldcare/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/presentation/blocs/auth/auth_event.dart';
import 'package:eldcare/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/presentation/screens/login%20&%20singup/rolesection/roleselection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/font.dart';

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
        body: const Center(
          child: Text(
            'Welcome to EldCare',
            style: AppFonts.headline1,
          ),
        ),
      ),
    );
  }
}
