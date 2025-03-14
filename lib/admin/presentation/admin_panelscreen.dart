import 'package:eldcare/admin/blocs/users/users_bloc.dart';
import 'package:eldcare/admin/presentation/delivery/delivery_charges.dart';
import 'package:eldcare/admin/presentation/doctors/doctor_approval_screen.dart';
import 'package:eldcare/admin/presentation/report/reports_page.dart';
import 'package:eldcare/admin/presentation/sidebar.dart';
import 'package:eldcare/admin/repository/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/admin/presentation/users/userspage.dart';
import 'package:eldcare/admin/presentation/dashboard/dashboard.dart';
import 'package:eldcare/admin/presentation/shops/shoppage.dart';
import 'package:eldcare/admin/blocs/shop/shop_bloc.dart';
import 'package:eldcare/admin/repository/shop_repositry.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/admin/blocs/doctor_approval/doctor_approval_bloc.dart';
import 'package:eldcare/admin/repository/doctor_approval_repository.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  AdminPanelState createState() => AdminPanelState();
}

class AdminPanelState extends State<AdminPanel> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: const Text('Admin Panel'),
        ),
        drawer: Sidebar(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
            Navigator.pop(context);
          },
        ),
        body: _buildPageContent(),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0:
        return const Dashboard();
      case 1:
        return BlocProvider<UserBloc>(
          create: (context) => UserBloc(UserRepository())..add(FetchUsers()),
          child: const UserManagementPage(),
        );
      case 2:
        return MultiBlocProvider(
          providers: [
            BlocProvider<AdminShopBloc>(
              create: (context) =>
                  AdminShopBloc(shopRepository: ShopRepository())
                    ..add(AdminLoadShops()),
            ),
            BlocProvider<UserBloc>(
              create: (context) => UserBloc(UserRepository()),
            ),
          ],
          child: const ShopsPage(),
        );
      case 3:
        return const DeliveryChargesPage();
      case 4:
        return BlocProvider(
          create: (context) => DoctorApprovalBloc(
            repository: DoctorApprovalRepository(),
          ),
          child: const DoctorApprovalScreen(),
        );
      case 5:
        return const ReportsAnalyticsPage();
      default:
        return const Center(child: Text('Page not implemented'));
    }
  }
}
