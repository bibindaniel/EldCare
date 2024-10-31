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

class FakeShop extends Fake implements Shop {}

void main() {
  print('\n🚀 Starting UpdateShopPage Tests...\n');

  late MockShopRepository mockRepository;
  late MockShopBloc mockBloc;
  late Shop testShop;

  setUpAll(() {
    print('📦 Registering fallback values...');
    registerFallbackValue(FakeShop());
  });

  setUp(() {
    print('\n📋 Setting up test...');
    mockRepository = MockShopRepository();
    mockBloc = MockShopBloc();

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

    when(() => mockRepository.updateShop(any())).thenAnswer((_) async => {});
    when(() => mockBloc.state).thenReturn(ShopInitialState());
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<ShopBloc>.value(
        value: mockBloc,
        child: Scaffold(
          body: UpdateShopPage(
            shop: testShop,
            shopRepository: mockRepository,
          ),
        ),
      ),
    );
  }

  group('UpdateShopPage', () {
    testWidgets('displays initial shop details', (WidgetTester tester) async {
      print('🔍 Testing initial shop display...');

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Test Shop'), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);

      print('✅ Initial shop display test passed');
    });

    testWidgets('shows validation for invalid phone',
        (WidgetTester tester) async {
      print('🔍 Testing phone validation...');

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find TextFormField by type since it's the only one for phone
      final phoneField = find.byType(TextFormField);
      expect(phoneField, findsOneWidget,
          reason: 'Should find exactly one TextFormField');

      print('📝 Entering invalid phone number...');
      await tester.enterText(phoneField, '123');
      await tester.pump();

      print('🔘 Tapping submit button...');
      final submitButton = find.byType(ElevatedButton);
      expect(submitButton, findsOneWidget,
          reason: 'Should find exactly one ElevatedButton');

      await tester.tap(submitButton);
      await tester.pump();

      expect(find.text('Invalid phone number'), findsOneWidget);

      print('✅ Phone validation test passed');
    });

    // Optional: Add a test for loading state
    testWidgets('shows loading indicator', (WidgetTester tester) async {
      print('🔍 Testing loading state...');

      when(() => mockBloc.state).thenReturn(ShopLoadingState());

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      print('✅ Loading state test passed');
    });
  });

  print('\n🎉 All UpdateShopPage Tests Completed!\n');
}
