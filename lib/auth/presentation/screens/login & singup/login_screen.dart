import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_event.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/auth/presentation/screens/login%20&%20singup/rolesection/roleselection_screen.dart';
import 'package:eldcare/auth/presentation/screens/login%20&%20singup/rolesection/user_redirection.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/auth/presentation/widgets/textboxwidget.dart';
import 'package:eldcare/auth/presentation/widgets/button_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _forgotPassword(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Forgot Password",
            style: TextStyle(color: kDarkColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter your email address to reset your password.",
                style: TextStyle(color: kDarkColor),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: kPrimaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                if (emailController.text.isNotEmpty) {
                  BlocProvider.of<AuthBloc>(context).add(
                    ForgotPasswordEvent(email: emailController.text),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                "Submit",
                style: TextStyle(color: kPrimaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserRedirection()),
          );
        } else if (state is RoleSelectionNeeded) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RoleSelectionScreen(userId: state.user.uid),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: kErrorColor,
            ),
          );
        } else if (state is Unauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password reset email sent"),
              backgroundColor: kSuccessColor,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Image.asset(
                            "assets/images/icons/eldcare.png",
                            height: 200,
                            width: 200,
                            color: kPrimaryColor,
                          ),
                          const Text(
                            "ELDCARE",
                            style: AppFonts.headline1,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login',
                          style:
                              AppFonts.headline2.copyWith(color: kPrimaryColor),
                        ),
                        const SizedBox(height: 50),
                        CustomTextFormField(
                          key: const ValueKey('emailField'),
                          controller: _emailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        CustomTextFormField(
                          key: const ValueKey('passwordField'),
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: true,
                        ),
                        const SizedBox(height: 25),
                        CustomButton(
                          key: const ValueKey('loginButton'),
                          text: 'Log In',
                          onPressed: () {
                            BlocProvider.of<AuthBloc>(context).add(
                              LoginEvent(
                                email: _emailController.text,
                                password: _passwordController.text,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        CustomButton(
                          text: 'Sign in with Google',
                          onPressed: () {
                            BlocProvider.of<AuthBloc>(context)
                                .add(GoogleSignInEvent());
                          },
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: TextButton(
                            onPressed: () => _forgotPassword(context),
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: kPrimaryColor),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: AppFonts.bodyText2
                                  .copyWith(color: const Color(0xFF837E93)),
                            ),
                            const SizedBox(width: 2.5),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pushNamed('/register');
                              },
                              child: Text(
                                'Sign Up',
                                style: AppFonts.bodyText2
                                    .copyWith(color: kPrimaryColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
