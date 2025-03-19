import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/shared/repositories/appointment_repository.dart';
import 'appointment_bloc.dart';

class AppointmentProvider extends StatelessWidget {
  final Widget child;

  const AppointmentProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppointmentBloc(
        appointmentRepository: AppointmentRepository(),
      ),
      child: child,
    );
  }
}
