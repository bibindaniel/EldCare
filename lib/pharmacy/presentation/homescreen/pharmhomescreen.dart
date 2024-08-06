import 'package:eldcare/pharmacy/presentation/homescreen/homescreencontent.dart';
import 'package:eldcare/pharmacy/presentation/profile/profilecheck.dart';
import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_event.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';

class PharmacistHomeScreen extends StatelessWidget {
  const PharmacistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: const PharmacistHomeContent(),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildBottomNavigationBar(),
        drawer: _buildDrawer(context),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryColor,
      leading: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String imageUrl = 'assets/images/user/user1.jpg';
                  if (state is Authenticated &&
                      state.user.photoURL != null &&
                      state.user.photoURL!.isNotEmpty) {
                    imageUrl = state.user.photoURL!;
                  }
                  return CircleAvatar(
                    radius: 15,
                    backgroundImage: AssetImage(imageUrl),
                  );
                },
              ),
            ),
          );
        },
      ),
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Text('Hey, ${state.user.displayName ?? 'Pharmacist'}',
                style: AppFonts.headline3);
          } else {
            return const Text('Hey, Pharmacist', style: AppFonts.headline3);
          }
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_active, color: kWhiteColor),
          onPressed: () {
            // Add notification action here
          },
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Add your button action here
      },
      backgroundColor: kThridColor,
      child: const Icon(Icons.add),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildNavItem(Icons.home, 'Home'),
            _buildNavItem(Icons.inventory, 'Inventory'),
            _buildNavItem(Icons.notifications, 'Notifications'),
            _buildNavItem(Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        // Handle navigation
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: kThridColor,
          ),
          Text(label),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: kPrimaryColor,
            ),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  String imageUrl = 'assets/images/user/user1.jpg';
                  if (state.user.photoURL != null &&
                      state.user.photoURL!.isNotEmpty) {
                    imageUrl = state.user.photoURL!;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: imageUrl.startsWith('http')
                            ? NetworkImage(imageUrl)
                            : AssetImage(imageUrl) as ImageProvider,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.user.displayName ?? 'Pharmacist',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        state.user.email ?? '',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  );
                } else {
                  return const Text(
                    'User Info',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  );
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PharmacistProfileCheckPage(
                        pharmacistId: authState.user.uid),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutEvent());
            },
          ),
        ],
      ),
    );
  }
}
