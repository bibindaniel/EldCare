import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_event.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_state.dart';
import 'package:eldcare/pharmacy/model/pharmacist.dart';
import 'package:eldcare/pharmacy/presentation/profile/pharmacist_profile_update.dart';
import 'package:eldcare/pharmacy/presentation/profile/profilecompletionpage.dart';
import 'package:eldcare/pharmacy/repository/pharmacist_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PharmacistProfileCheckPage extends StatelessWidget {
  final String pharmacistId;

  const PharmacistProfileCheckPage({super.key, required this.pharmacistId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PharmacistProfileBloc(PharmacistProfileRepository())
        ..add(LoadPharmacistProfile(pharmacistId)),
      child: BlocConsumer<PharmacistProfileBloc, PharmacistProfileState>(
        listener: (context, state) {
          if (state is PharmacistProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}')),
            );
          } else if (state is PharmacistProfileLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToAppropriateScreen(context, state.pharmacistProfile);
            });
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Center(
              child: state is PharmacistProfileLoading
                  ? const CircularProgressIndicator()
                  : const Text('Checking profile status...'),
            ),
          );
        },
      ),
    );
  }

  void _navigateToAppropriateScreen(
      BuildContext context, PharmacistProfile profile) {
    if (profile.isProfileComplete) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<PharmacistProfileBloc>(),
            child: PharmacistProfileUpdatePage(pharmacistId: pharmacistId),
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<PharmacistProfileBloc>(),
            child: PharmacistProfileCompletionPage(pharmacistId: pharmacistId),
          ),
        ),
      );
    }
  }
}
