import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/pharmacy/blocs/shop/shop_bloc.dart';
import 'package:eldcare/pharmacy/model/shop.dart';
import 'package:eldcare/pharmacy/presentation/shop/updateshop.dart';
import 'package:eldcare/pharmacy/repository/shop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockShopRepository extends Mock implements ShopRepository {}

class MockShopBloc extends MockBloc<ShopEvent, ShopState> implements ShopBloc {}

void main() {
  late MockShopRepository mockShopRepository;
  late MockShopBloc mockShopBloc;
  late Shop testShop;

  setUpAll(() {
    registerFallbackValue(
      UpdateShopEvent(
        Shop(
          id: 'test_id',
          name: 'Test Shop',
          phoneNumber: '9876543210',
          email: 'test@shop.com',
          licenseNumber: 'LICENSE123',
          address: 'Test Address',
          location: const GeoPoint(0.0, 0.0),
          isVerified: false,
          ownerId: 'owner_id',
          createdAt: DateTime(2024, 1, 1),
        ),
      ),
    );
  });

  setUp(() {
    mockShopRepository = MockShopRepository();
    mockShopBloc = MockShopBloc();
    testShop = Shop(
      id: 'test_id',
      name: 'Test Shop',
      phoneNumber: '9876543210',
      email: 'test@shop.com',
      licenseNumber: 'LICENSE123',
      address: 'Test Address',
      location: const GeoPoint(0.0, 0.0),
      isVerified: false,
      ownerId: 'owner_id',
      createdAt: DateTime(2024, 1, 1),
    );
    when(() => mockShopBloc.state).thenReturn(ShopInitialState());
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: BlocProvider<ShopBloc>.value(
            value: mockShopBloc,
            child: UpdateShopPage(
              shopRepository: mockShopRepository,
              shop: testShop,
            ),
          ),
        ),
      ),
    );
  }

  group('UpdateShopPage', () {
    testWidgets('should update phone number', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find and enter text in phone field
      final phoneField = find.byType(TextFormField).first;
      await tester.enterText(phoneField, '9876543211');
      await tester.pump();

      // Find and scroll to submit button
      final submitButton = find.byKey(const Key('submit_button'));
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify bloc event
      verify(() => mockShopBloc.add(any())).called(1);
    });

    testWidgets('should show error for invalid phone',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find and enter invalid phone
      final phoneField = find.byType(TextFormField).first;
      await tester.enterText(phoneField, '123');
      await tester.pump();

      // Find and scroll to submit button
      final submitButton = find.byKey(const Key('submit_button'));
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify error text
      expect(find.text('Invalid phone number'), findsOneWidget);
    });

    testWidgets('should show loading indicator', (WidgetTester tester) async {
      when(() => mockShopBloc.state).thenReturn(ShopLoadingState());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
