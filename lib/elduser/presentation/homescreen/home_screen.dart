import 'package:eldcare/elduser/blocs/VerifiedShopListing/verified_shop_listing_bloc.dart';
import 'package:eldcare/elduser/blocs/medicine/medicine_bloc.dart';
import 'package:eldcare/elduser/presentation/appoinment/appoinment_screen.dart';
import 'package:eldcare/elduser/presentation/homescreen/homecontent.dart';
import 'package:eldcare/elduser/presentation/homescreen/ttstest.dart';
import 'package:eldcare/elduser/presentation/medcine_schedule/medicine_schedule.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_event.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/auth/presentation/screens/login%20&%20singup/rolesection/roleselection_screen.dart';
import 'package:eldcare/elduser/presentation/medcine_schedule/add_schedule.dart';
import 'package:eldcare/elduser/presentation/order/orderscreen.dart';
import 'package:eldcare/elduser/presentation/shop/shop_screen.dart';
import 'package:eldcare/elduser/presentation/userprofile/profilecheck.dart';
import 'package:eldcare/elduser/repository/shoplisting_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/elduser/blocs/navigation/navigation_bloc.dart';
import 'package:eldcare/elduser/blocs/navigation/navigation_event.dart';
import 'package:eldcare/elduser/blocs/navigation/navigation_state.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavigationBloc()),
        BlocProvider(
          create: (context) => MedicineBloc()
            ..add(FetchMedicinesForDate(DateTime.now()))
            ..add(FetchCompletedMedicines()),
        ),
        BlocProvider(
            create: (context) => VerifiedShopListingBloc(
                  repository: VerifiedShopListingRepository(),
                )),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          } else if (state is RoleSelectionNeeded) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    RoleSelectionScreen(userId: state.user.uid),
              ),
            );
          }
        },
        child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, navigationState) {
            return Scaffold(
              appBar: _buildAppBar(context),
              body: _getSelectedScreen(navigationState.currentItem),
              floatingActionButton: _buildFloatingActionButton(context),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar:
                  _buildBottomNavigationBar(context, navigationState),
              drawer: _buildDrawer(context),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryColor,
      elevation: 0,
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
            return Text('Hey, ${state.user.displayName ?? 'User'}',
                style: AppFonts.headline3Light);
          } else {
            return const Text('Hey, User', style: AppFonts.headline3);
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

  Widget _getSelectedScreen(NavigationItem item) {
    switch (item) {
      case NavigationItem.home:
        return const HomeContent();
      case NavigationItem.schedule:
        return const ScheduleScreen();
      case NavigationItem.shop:
        return const ShopScreen();
      case NavigationItem.appointment:
        return const AppointmentScreen();
    }
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddMedicinePage()));
      },
      backgroundColor: kAccentColor,
      child: const Icon(Icons.add, color: kWhiteColor),
    );
  }

  Widget _buildBottomNavigationBar(
      BuildContext context, NavigationState navigationState) {
    return BottomAppBar(
      color: kLightPrimaryColor,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildNavItem(context, Icons.home, 'Home', NavigationItem.home,
                navigationState),
            _buildNavItem(context, Icons.calendar_today, 'Schedule',
                NavigationItem.schedule, navigationState),
            const SizedBox(width: 40),
            _buildNavItem(context, Icons.shopping_cart, 'Shop',
                NavigationItem.shop, navigationState),
            _buildNavItem(context, Icons.medical_services, 'Appointment',
                NavigationItem.appointment, navigationState),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      NavigationItem item, NavigationState state) {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        context.read<NavigationBloc>().add(_getNavigationEvent(item));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: state.currentItem == item
                ? kSecondaryColor
                : kSecondaryTextColor,
          ),
          Text(
            label,
            style: TextStyle(
              color: state.currentItem == item
                  ? kSecondaryColor
                  : kSecondaryTextColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  NavigationEvent _getNavigationEvent(NavigationItem item) {
    switch (item) {
      case NavigationItem.home:
        return NavigateToHome();
      case NavigationItem.schedule:
        return NavigateToSchedule();
      case NavigationItem.shop:
        return NavigateToShop();
      case NavigationItem.appointment:
        return NavigateToAppointment();
    }
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
                        state.user.displayName ?? 'User',
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
                    builder: (context) =>
                        ProfileCheckPage(userId: authState.user.uid),
                  ),
                );
              }
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: const Text('My Orders'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrdersScreen(userId: state.user.uid),
                      ),
                    );
                  },
                );
              } else {
                return const SizedBox.shrink();
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
            leading: const Icon(Icons.record_voice_over),
            title: const Text('Test TTS'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TTSTestPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              googleSignIn.signOut();
              context.read<AuthBloc>().add(LogoutEvent());
            },
          ),
        ],
      ),
    );
  }
}
