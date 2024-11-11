import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_navigation/pharmacist_navigation_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_event.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_state.dart';
import 'package:eldcare/pharmacy/presentation/order/pharmacist_order_screen.dart';
import 'package:eldcare/pharmacy/presentation/profile/profilecompletionpage.dart';
import 'package:eldcare/pharmacy/repository/pharmacistorderrepositry.dart';
import 'package:eldcare/pharmacy/repository/shop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_event.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/pharmacy/blocs/shop/shop_bloc.dart';
import 'package:eldcare/pharmacy/presentation/homescreen/homescreencontent.dart';
import 'package:eldcare/pharmacy/presentation/inventory/inventorypage.dart';
import 'package:eldcare/pharmacy/presentation/shop/add_shop.dart';
import 'package:eldcare/pharmacy/presentation/analytics/pharmacy_analytics_page.dart';

class PharmacistHomeScreen extends StatelessWidget {
  const PharmacistHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PharmacistNavigationBloc()),
        BlocProvider(
          create: (context) {
            final authState = context.read<AuthBloc>().state;
            String? ownerId;
            if (authState is Authenticated) {
              ownerId = authState.user.uid;
              final bloc = ShopBloc(shopRepository: ShopRepository());
              bloc.add(LoadShopsEvent(ownerId: ownerId));
              return bloc;
            } else {
              return ShopBloc(shopRepository: ShopRepository());
            }
          },
        ),
        BlocProvider<PharmacistOrderBloc>(
          create: (context) => PharmacistOrderBloc(
              pharmacistOrderRepository: PharmacistOrderRepository()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: BlocBuilder<PharmacistNavigationBloc, PharmacistNavigationState>(
          builder: (context, navigationState) {
            return Scaffold(
              appBar: _buildAppBar(context),
              body: _getSelectedScreen(navigationState.currentItem, context),
              bottomNavigationBar:
                  _buildBottomNavigationBar(context, navigationState),
              floatingActionButton: _buildFloatingActionButton(context),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
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
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: kWhiteColor),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Text('Welcome, ${state.user.displayName ?? 'Pharmacist'}',
                style: AppFonts.headline3.copyWith(color: kWhiteColor));
          } else {
            return const Text('Welcome', style: AppFonts.headline3);
          }
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: kWhiteColor),
          onPressed: () {
            // Add notification action here
          },
        ),
      ],
    );
  }

  Widget _getSelectedScreen(NavigationItem item, BuildContext context) {
    switch (item) {
      case NavigationItem.shops:
        return const PharmacistHomeContent();
      case NavigationItem.inventory:
        return const InventoryPage();
      case NavigationItem.orders:
        return BlocProvider<PharmacistOrderBloc>(
          create: (context) => PharmacistOrderBloc(
            pharmacistOrderRepository: PharmacistOrderRepository(),
          ),
          child: const PharmacistOrdersScreen(),
        );
      case NavigationItem.analytics:
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          return PharmacyAnalyticsPage(shopId: authState.user.uid);
        }
        return const Center(child: Text('Please login to view analytics'));
      case NavigationItem.profile:
        return const Center(child: Text('Profile Screen'));
    }
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          _checkProfileAndNavigate(context, authState.user.uid);
        }
      },
      backgroundColor: kAccentColor,
      child: const Icon(Icons.add, color: kWhiteColor),
    );
  }

  void _checkProfileAndNavigate(BuildContext context, String pharmacistId) {
    final profileBloc = context.read<PharmacistProfileBloc>();
    profileBloc.add(LoadPharmacistProfile(pharmacistId));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BlocConsumer<PharmacistProfileBloc, PharmacistProfileState>(
          listener: (context, state) {
            if (state is PharmacistProfileLoaded) {
              Navigator.of(context).pop(); // Close the loading dialog
              if (state.pharmacistProfile.isProfileComplete) {
                _navigateToAddShop(context);
              } else {
                _showCompleteProfileDialog(context, pharmacistId);
              }
            } else if (state is PharmacistProfileError) {
              Navigator.of(context).pop(); // Close the loading dialog
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error checking profile status: ${state.error}'),
              ));
            }
          },
          builder: (context, state) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state is PharmacistProfileLoading)
                    const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(state is PharmacistProfileLoading
                      ? "Checking profile status..."
                      : "Please wait..."),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToAddShop(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddShopPage(
        shopRepository: ShopRepository(),
      ),
    ));
  }

  void _showCompleteProfileDialog(BuildContext context, String pharmacistId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Complete Your Profile"),
          content: const Text(
              "Please complete your profile before adding a new shop."),
          actions: <Widget>[
            TextButton(
              child: const Text("Complete Profile"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<PharmacistProfileBloc>(),
                    child: PharmacistProfileCompletionPage(
                        pharmacistId: pharmacistId),
                  ),
                ));
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(
      BuildContext context, PharmacistNavigationState navigationState) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: kSurfaceColor,
      child: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(context, Icons.store, 'Shops', NavigationItem.shops,
                navigationState),
            _buildNavItem(context, Icons.inventory, 'Inventory',
                NavigationItem.inventory, navigationState),
            const SizedBox(width: 40),
            _buildNavItem(context, Icons.shopping_cart, 'Orders',
                NavigationItem.orders, navigationState),
            _buildNavItem(context, Icons.analytics, 'Analytics',
                NavigationItem.analytics, navigationState),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      NavigationItem item, PharmacistNavigationState state) {
    final isSelected = state.currentItem == item;
    return InkWell(
      onTap: () {
        context.read<PharmacistNavigationBloc>().add(_getNavigationEvent(item));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? kPrimaryColor : kSecondaryTextColor,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? kPrimaryColor : kSecondaryTextColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  PharmacistNavigationEvent _getNavigationEvent(NavigationItem item) {
    switch (item) {
      case NavigationItem.shops:
        return NavigateToShops();
      case NavigationItem.inventory:
        return NavigateToInventory();
      case NavigationItem.orders:
        return NavigateToOrders();
      case NavigationItem.analytics:
        return NavigateToAnalytics();
      case NavigationItem.profile:
        return NavigateToProfile();
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
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: state.user.photoURL != null
                            ? NetworkImage(state.user.photoURL!)
                            : const AssetImage(
                                    'assets/images/default_avatar.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.user.displayName ?? 'Pharmacist',
                        style: AppFonts.headline4.copyWith(color: kWhiteColor),
                      ),
                      Text(
                        state.user.email ?? '',
                        style: AppFonts.bodyText2
                            .copyWith(color: kLightPrimaryColor),
                      ),
                    ],
                  );
                } else {
                  return const Text(
                    'Eldcare Pharmacy',
                    style: TextStyle(color: kWhiteColor, fontSize: 24),
                  );
                }
              },
            ),
          ),
          _buildDrawerItem(context, Icons.person, 'Profile', () {
            // Navigate to profile
          }),
          _buildDrawerItem(context, Icons.settings, 'Settings', () {
            // Navigate to settings
          }),
          _buildDrawerItem(context, Icons.help, 'Help & Support', () {
            // Navigate to help & support
          }),
          const Divider(),
          _buildDrawerItem(context, Icons.logout, 'Logout', () {
            context.read<AuthBloc>().add(LogoutEvent());
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryColor),
      title: Text(title, style: AppFonts.bodyText1),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
