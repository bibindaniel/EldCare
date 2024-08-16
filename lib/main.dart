import 'package:eldcare/admin/blocs/users/users_bloc.dart';
import 'package:eldcare/admin/presentation/users/userspage.dart';
import 'package:eldcare/admin/repository/users.dart';
import 'package:eldcare/core/theme/routes/myroutes.dart';
import 'package:eldcare/elduser/blocs/medicine/medicine_bloc.dart';
import 'package:eldcare/elduser/blocs/navigation/navigation_bloc.dart';
import 'package:eldcare/elduser/blocs/shopmedicines/shop_medicines_bloc.dart';
import 'package:eldcare/elduser/blocs/userprofile/userprofile_bloc.dart';
import 'package:eldcare/elduser/presentation/homescreen/notification_service.dart';
import 'package:eldcare/elduser/repository/order_repo.dart';
import 'package:eldcare/elduser/repository/shop_medicine_repo.dart';
import 'package:eldcare/elduser/repository/userprofile_repository.dart';
import 'package:eldcare/firebase_options.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_event.dart';
import 'package:eldcare/auth/presentation/screens/splashscreen.dart';
import 'package:eldcare/pharmacy/blocs/category/category_bloc.dart';
import 'package:eldcare/pharmacy/blocs/inventory/inventory_bloc.dart';
import 'package:eldcare/pharmacy/blocs/medicine_name/medicine_name_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_bloc.dart';
import 'package:eldcare/pharmacy/blocs/shop/shop_bloc.dart';
import 'package:eldcare/pharmacy/repository/category_repo.dart';
import 'package:eldcare/pharmacy/repository/inventory_repository.dart';
import 'package:eldcare/pharmacy/repository/medicine_repositry.dart';
import 'package:eldcare/pharmacy/repository/pharmacist_profile_repository.dart';
import 'package:eldcare/pharmacy/repository/shop.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService().init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => CategoryRepository()),
        RepositoryProvider(create: (_) => MedicineNameRepository()),
        RepositoryProvider(create: (_) => InventoryRepository())
      ],
      child: MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) => AuthBloc()..add(CheckLoginStatus())),
            BlocProvider(create: (context) => AuthBloc()),
            BlocProvider(
              create: (context) =>
                  UserBloc(UserRepository())..add(FetchUsers()),
              child: const UsersPage(),
            ),
            BlocProvider(
                create: (context) => UserProfileBloc(UserProfileRepository())),
            BlocProvider(
                create: (context) =>
                    PharmacistProfileBloc(PharmacistProfileRepository())),
            BlocProvider<ShopBloc>(
              create: (context) => ShopBloc(
                shopRepository: ShopRepository(),
              ),
            ),
            BlocProvider(
              create: (context) => CategoryBloc(
                repository: RepositoryProvider.of<CategoryRepository>(context),
              ),
            ),
            BlocProvider(
              create: (context) => MedicineNameBloc(
                repository:
                    RepositoryProvider.of<MedicineNameRepository>(context),
              ),
            ),
            BlocProvider(
              create: (context) => InventoryBloc(
                repository: RepositoryProvider.of<InventoryRepository>(context),
              ),
            ),
            BlocProvider(create: (context) => NavigationBloc()),
            BlocProvider(
                create: (context) => MedicineBloc()
                  ..add(FetchMedicinesForDate(DateTime.now()))
                  ..add(FetchCompletedMedicines())),
            BlocProvider<ShopMedicinesBloc>(
              create: (context) => ShopMedicinesBloc(
                shopMedicineRepository: ShopMedicineRepository(),
                orderRepository: OrderRepository(),
              ),
            ),
          ],
          child: MaterialApp(
            navigatorKey: NotificationService.navigatorKey,
            onGenerateRoute: Myroutes.generateRoute,
            initialRoute: Myroutes.splash,
            home: const Splashscreen(),
            debugShowCheckedModeBanner: false,
          )),
    );
  }
}
