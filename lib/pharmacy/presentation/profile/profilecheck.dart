import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_event.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_state.dart';
import 'package:eldcare/pharmacy/presentation/profile/Pharmacist_profile_update.dart';
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
              SnackBar(content: Text('Error loading profile: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
          if (state is PharmacistProfileLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is PharmacistProfileLoaded) {
            if (state.pharmacistProfile.isProfileComplete) {
              print("entreed");

              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<PharmacistProfileBloc>(),
                      child: PharmacistProfileUpdatePage(
                          pharmacistId: pharmacistId),
                    ),
                  ),
                );
              });
            } else {
              print("entred");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<PharmacistProfileBloc>(),
                      child: PharmacistProfileCompletionPage(
                          pharmacistId: pharmacistId),
                    ),
                  ),
                );
              });
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const Scaffold(
              body: Center(child: Text('Failed to load profile')),
            );
          }
        },
      ),
    );
  }
}
