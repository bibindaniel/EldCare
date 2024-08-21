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
import 'package:eldcare/pharmacy/presentation/profile/profilecheck.dart';
import 'package:eldcare/pharmacy/presentation/shop/add_shop.dart';

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
            pharmacistOrderRepository: PharmacistOrderRepository(),
            orderRepository: PharmacistOrderRepository(),
          ),
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

  Widget _getSelectedScreen(NavigationItem item) {
    switch (item) {
      case NavigationItem.shops:
        return const PharmacistHomeContent();
      case NavigationItem.inventory:
        return const InventoryPage();
      case NavigationItem.orders:
        return BlocProvider<PharmacistOrderBloc>(
          create: (context) => PharmacistOrderBloc(
            pharmacistOrderRepository: PharmacistOrderRepository(),
            orderRepository: PharmacistOrderRepository(),
          ),
          child: const PharmacistOrdersScreen(),
        );
      case NavigationItem.analytics:
        return const Center(child: Text('Analytics Screen'));
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
      backgroundColor: kThridColor,
      child: const Icon(Icons.add),
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
      notchMargin: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildNavItem(context, Icons.store, 'Shops', NavigationItem.shops,
                navigationState),
            _buildNavItem(context, Icons.inventory, 'Inventory',
                NavigationItem.inventory, navigationState),
            const SizedBox(width: 40), // Space for the FloatingActionButton
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
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        context.read<PharmacistNavigationBloc>().add(_getNavigationEvent(item));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: state.currentItem == item ? kPrimaryColor : Colors.grey,
          ),
          Text(label),
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
