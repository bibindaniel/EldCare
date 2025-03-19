import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/doctor/repositories/doctor_repository.dart';
import 'doctor_registration_bloc.dart';

class DoctorRegistrationProvider extends StatelessWidget {
  final Widget child;

  const DoctorRegistrationProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorRegistrationBloc(
        doctorRepository: DoctorRepository(),
      ),
      child: child,
    );
  }
}
