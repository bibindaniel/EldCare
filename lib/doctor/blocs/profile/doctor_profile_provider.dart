import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/doctor/repository/doctor_repository.dart';
import 'doctor_profile_bloc.dart';

class DoctorProfileProvider extends StatelessWidget {
  final Widget child;

  const DoctorProfileProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorProfileBloc(
        doctorRepository: DoctorRepository(),
      ),
      child: child,
    );
  }
}
