import 'package:eldcare/admin/repository/delivery_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/elduser/blocs/shopmedicines/shop_medicines_bloc.dart';
import 'package:eldcare/elduser/repository/shop_medicine_repo.dart';
import 'package:eldcare/elduser/repository/order_repo.dart';
import 'package:eldcare/elduser/presentation/shop/shop_medicinescreen.dart';
import 'package:eldcare/elduser/presentation/shop/cart_screen.dart';

class ShopWrapper extends StatelessWidget {
  final String shopId;
  final String shopName;

  const ShopWrapper({super.key, required this.shopId, required this.shopName});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ShopMedicineRepository>(
          create: (context) => ShopMedicineRepository(),
        ),
        RepositoryProvider<OrderRepository>(
          create: (context) => OrderRepository(),
        ),
        RepositoryProvider<DeliveryChargesRepository>(
          create: (context) => DeliveryChargesRepository(),
        ),
      ],
      child: BlocProvider<ShopMedicinesBloc>(
        create: (context) => ShopMedicinesBloc(
          shopMedicineRepository: context.read<ShopMedicineRepository>(),
          deliveryChargesRepository: context.read<DeliveryChargesRepository>(),
          orderRepository: OrderRepository(),
        )..add(LoadShopMedicines(shopId)),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: ShopMedicinesScreen(shopName: shopName, shopId: shopId),
          routes: {
            '/cart': (context) =>
                CartScreen(shopId: shopId, shopName: shopName),
          },
        ),
      ),
    );
  }
}
