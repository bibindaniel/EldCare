import 'package:eldcare/elduser/presentation/userprofile/profileupdate.dart';
import 'package:eldcare/elduser/presentation/userprofile/userprofilecompletion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/elduser/blocs/userprofile/userprofile_bloc.dart';
import 'package:eldcare/elduser/repository/userprofile_repository.dart';

class ProfileCheckPage extends StatelessWidget {
  final String userId;

  const ProfileCheckPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileBloc(UserProfileRepository())
        ..add(LoadUserProfile(userId)),
      child: BlocConsumer<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading profile: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is UserProfileLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (state.userProfile.isProfileComplete) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<UserProfileBloc>(),
                      child: ProfileUpdatePage(userId: userId),
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<UserProfileBloc>(),
                      child: ProfileCompletionPage(userId: userId),
                    ),
                  ),
                );
              }
            });
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
