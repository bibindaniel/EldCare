import 'package:eldcare/admin/blocs/delivery_charges/delivery_charges_bloc.dart';
import 'package:eldcare/admin/blocs/users/users_bloc.dart';
import 'package:eldcare/admin/repository/delivery_repo.dart';
import 'package:eldcare/admin/repository/users.dart';
import 'package:eldcare/core/theme/routes/myroutes.dart';
import 'package:eldcare/delivery/blocs/delivery_order/delivery_order_bloc.dart';
import 'package:eldcare/delivery/repository/delivery_order_repo.dart';
import 'package:eldcare/doctor/repositories/doctor_schedule_repository.dart';
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
import 'package:eldcare/pharmacy/blocs/pharmacist_order/pharmacist_order_bloc.dart';
import 'package:eldcare/pharmacy/blocs/pharmacists/pharmacists_profile_bloc.dart';
import 'package:eldcare/pharmacy/blocs/shop/shop_bloc.dart';
import 'package:eldcare/pharmacy/repository/category_repo.dart';
import 'package:eldcare/pharmacy/repository/inventory_repository.dart';
import 'package:eldcare/pharmacy/repository/medicine_repositry.dart';
import 'package:eldcare/pharmacy/repository/pharmacist_profile_repository.dart';
import 'package:eldcare/pharmacy/repository/pharmacistorderrepositry.dart';
import 'package:eldcare/pharmacy/repository/shop.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';

// import 'package:flutter_driver/driver_extension.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final notificationService = NotificationService();
    await notificationService.init();

    final now = DateTime.now();
    final scheduledTime =
        now.add(const Duration(seconds: 10)); // Adjust as needed

    await notificationService.scheduleNotification(
      0,
      'Medicine Reminder',
      "It's time to take your medicine. The dosage is two pills.",
      scheduledTime,
    );

    return Future.value(true);
  });
}

void main() async {
  // enableFlutterDriverExtension();
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  tz.initializeTimeZones();
  await NotificationService().init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
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
        RepositoryProvider(create: (_) => MedicineRepository()),
        RepositoryProvider(create: (_) => InventoryRepository()),
        RepositoryProvider(create: (_) => ShopRepository()),
        RepositoryProvider(create: (_) => UserRepository()),
        RepositoryProvider(create: (_) => UserProfileRepository()),
        RepositoryProvider(create: (_) => PharmacistProfileRepository()),
        RepositoryProvider(create: (_) => ShopMedicineRepository()),
        RepositoryProvider(create: (_) => OrderRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => AuthBloc()..add(CheckLoginStatus())),
          BlocProvider(
              create: (context) =>
                  UserBloc(context.read<UserRepository>())..add(FetchUsers())),
          BlocProvider(
              create: (context) =>
                  UserProfileBloc(context.read<UserProfileRepository>())),
          BlocProvider(
              create: (context) => PharmacistProfileBloc(
                  context.read<PharmacistProfileRepository>())),
          BlocProvider(
              create: (context) =>
                  ShopBloc(shopRepository: context.read<ShopRepository>())),
          BlocProvider(
              create: (context) => CategoryBloc(
                  repository: context.read<CategoryRepository>(),
                  categoryRepository: CategoryRepository())),
          BlocProvider(
              create: (context) => MedicineNameBloc(
                  repository: context.read<MedicineRepository>(),
                  medicineRepository: MedicineRepository())),
          BlocProvider(
              create: (context) => InventoryBloc(
                  repository: context.read<InventoryRepository>(),
                  inventoryRepository: InventoryRepository())),
          BlocProvider(create: (context) => NavigationBloc()),
          BlocProvider(
              create: (context) => MedicineBloc()
                ..add(FetchMedicinesForDate(DateTime.now()))
                ..add(FetchCompletedMedicines())),
          BlocProvider(
            create: (context) => ShopMedicinesBloc(
              shopMedicineRepository: context.read<ShopMedicineRepository>(),
              orderRepository: context.read<OrderRepository>(),
              deliveryChargesRepository: DeliveryChargesRepository(),
            ),
          ),
          BlocProvider<DeliveryChargesBloc>(
            create: (context) => DeliveryChargesBloc(
              repository: DeliveryChargesRepository(),
            )..add(LoadDeliveryCharges()),
          ),
          BlocProvider<PharmacistOrderBloc>(
              create: (context) => PharmacistOrderBloc(
                  pharmacistOrderRepository: PharmacistOrderRepository())),
          BlocProvider(
            create: (context) => DeliveryOrderBloc(
              repository: DeliveryOrderRepository(),
            ),
          ),
          RepositoryProvider<DoctorScheduleRepository>(
            create: (context) => DoctorScheduleRepository(),
          ),
        ],
        child: MaterialApp(
          navigatorKey: NotificationService.navigatorKey,
          onGenerateRoute: Myroutes.generateRoute,
          initialRoute: Myroutes.splash,
          home: const Splashscreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
