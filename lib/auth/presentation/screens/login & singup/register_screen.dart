import 'package:eldcare/auth/presentation/screens/login%20&%20singup/rolesection/user_redirection.dart';
import 'package:eldcare/core/theme/routes/myroutes.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_event.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/auth/presentation/screens/login%20&%20singup/rolesection/roleselection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/auth/presentation/widgets/textboxwidget.dart';
import 'package:eldcare/auth/presentation/widgets/button_widget.dart';

class RegistrationScreen extends StatelessWidget {
  RegistrationScreen({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters long';
    }
    if (!RegExp(r"^[a-zA-Z\s\-\']+$").hasMatch(value)) {
      return 'Name should only contain letters, spaces, hyphens, and apostrophes';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            'Register',
                            style: AppFonts.headline2
                                .copyWith(color: kPrimaryColor),
                          ),
                          const SizedBox(height: 50),
                          CustomTextFormField(
                            controller: _nameController,
                            label: 'Name',
                            validator: _validateName,
                          ),
                          const SizedBox(height: 20),
                          CustomTextFormField(
                            controller: _emailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 20),
                          CustomTextFormField(
                            controller: _passwordController,
                            label: 'Password',
                            obscureText: true,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 20),
                          CustomTextFormField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            obscureText: true,
                            validator: _validateConfirmPassword,
                          ),
                          const SizedBox(height: 25),
                          CustomButton(
                            text: 'Sign Up',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                BlocProvider.of<AuthBloc>(context).add(
                                  RegisterEvent(
                                    name: _nameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Text(
                                'Already have an account?',
                                style: AppFonts.bodyText2
                                    .copyWith(color: const Color(0xFF837E93)),
                              ),
                              const SizedBox(width: 2.5),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(Myroutes.login);
                                },
                                child: Text(
                                  'Log In',
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
          ),
        );
      },
    );
  }
}
