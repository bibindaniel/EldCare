import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_event.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/delivery/blocs/delivery_order/delivery_order_bloc.dart';
import 'package:eldcare/delivery/presentation/homescreen/homescreen_content.dart';
import 'package:eldcare/delivery/repository/delivery_order_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/delivery/blocs/delivery_navigation/delivery_navigation_bloc.dart';
import 'package:eldcare/delivery/blocs/delivery_navigation/delivery_navigation_event.dart';
import 'package:eldcare/delivery/blocs/delivery_navigation/delivery_navigation_state.dart';

class DeliveryPersonnelHomeScreen extends StatelessWidget {
  const DeliveryPersonnelHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => DeliveryNavigationBloc()),
        BlocProvider(
          create: (context) => DeliveryOrderBloc(
            repository: DeliveryOrderRepository(),
          ),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: BlocBuilder<DeliveryNavigationBloc, DeliveryNavigationState>(
          builder: (context, navigationState) {
            return Scaffold(
              appBar: _buildAppBar(context),
              body: _getSelectedScreen(navigationState.currentItem),
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
                    backgroundColor: kLightPrimaryColor,
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
            return Text('Hey, ${state.user.displayName ?? 'Delivery Partner'}',
                style: AppFonts.headline4Light);
          } else {
            return Text('Hey, Delivery Partner',
                style: AppFonts.headline4Light);
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

  Widget _getSelectedScreen(DeliveryNavigationItem item) {
    switch (item) {
      case DeliveryNavigationItem.home:
        return const DeliveryPersonnelHomeContent();
      case DeliveryNavigationItem.orders:
        return _buildStaticOrdersScreen();
      case DeliveryNavigationItem.profile:
        return _buildStaticProfileScreen();
    }
  }

  Widget _buildStaticOrdersScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list_alt, size: 80, color: kPrimaryColor),
          const SizedBox(height: 20),
          Text('Orders', style: AppFonts.headline2),
          const SizedBox(height: 20),
          Text('You have 5 pending orders', style: AppFonts.bodyText1),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('View Orders'),
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticProfileScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                AssetImage('assets/images/delivery/default_avatar.jpg'),
          ),
          SizedBox(height: 20),
          Text('John Doe', style: AppFonts.headline2),
          SizedBox(height: 10),
          Text('Delivery Partner', style: AppFonts.bodyText1),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('john.doe@example.com'),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('+1 234 567 8900'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('Edit Profile'),
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(
      BuildContext context, DeliveryNavigationState navigationState) {
    return BottomNavigationBar(
      currentIndex:
          DeliveryNavigationItem.values.indexOf(navigationState.currentItem),
      onTap: (index) {
        context
            .read<DeliveryNavigationBloc>()
            .add(_getNavigationEvent(DeliveryNavigationItem.values[index]));
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: kSecondaryTextColor,
      backgroundColor: kWhiteColor,
      elevation: 8,
    );
  }

  DeliveryNavigationEvent _getNavigationEvent(DeliveryNavigationItem item) {
    switch (item) {
      case DeliveryNavigationItem.home:
        return NavigateToDeliveryHome();
      case DeliveryNavigationItem.orders:
        return NavigateToDeliveryOrders();
      case DeliveryNavigationItem.profile:
        return NavigateToDeliveryProfile();
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
                  String imageUrl = 'assets/images/delivery/default_avatar.jpg';
                  if (state.user.photoURL != null &&
                      state.user.photoURL!.isNotEmpty) {
                    imageUrl = state.user.photoURL!;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: imageUrl.startsWith('http')
                            ? NetworkImage(imageUrl)
                            : AssetImage(imageUrl) as ImageProvider,
                        backgroundColor: kLightPrimaryColor,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.user.displayName ?? 'Delivery Partner',
                        style: AppFonts.headline5Light,
                      ),
                      Text(
                        state.user.email ?? '',
                        style: AppFonts.bodyText2Light,
                      ),
                    ],
                  );
                } else {
                  return Text(
                    'Delivery Partner Info',
                    style: AppFonts.headline4Light,
                  );
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: kPrimaryColor),
            title: Text('Profile', style: AppFonts.bodyText1),
            onTap: () {
              Navigator.pop(context);
              context
                  .read<DeliveryNavigationBloc>()
                  .add(NavigateToDeliveryProfile());
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: kPrimaryColor),
            title: Text('Settings', style: AppFonts.bodyText1),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: kErrorColor),
            title: Text('Logout', style: AppFonts.bodyText1),
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
