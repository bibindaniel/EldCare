import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/elduser/models/address.dart';
import 'package:eldcare/elduser/models/delivary_address.dart';
import 'package:eldcare/elduser/presentation/shop/edit_delivery_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  print('\n🚀 Starting EditAddressScreen Tests...\n');

  final testAddress = DeliveryAddress(
    id: 'test_id',
    label: 'Home',
    address: Address(
      id: 'address_id',
      houseName: 'Test House',
      street: 'Test Street',
      city: 'Test City',
      state: 'Test State',
      postalCode: '123456',
      location: const GeoPoint(0.0, 0.0),
    ),
    isDefault: true,
  );

  Widget createTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: EditAddressScreen(
          userId: 'test_user',
          address: testAddress,
          onAddressUpdated: (address) {
            print('📝 Address Updated Callback Triggered');
          },
        ),
      ),
    );
  }

  group('EditAddressScreen', () {
    setUp(() {
      print('\n📋 Setting up test...');
    });

    tearDown(() {
      print('🧹 Cleaning up test...\n');
    });

    testWidgets('displays initial address details',
        (WidgetTester tester) async {
      print('🔍 Testing initial address display...');

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test House'), findsOneWidget);
      expect(find.text('Test Street'), findsOneWidget);
      expect(find.text('Test City'), findsOneWidget);

      print('✅ Initial address display test passed');
    });

    testWidgets('shows validation messages', (WidgetTester tester) async {
      print('🔍 Testing form validation...');

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Clear first field and submit
      print('📝 Clearing address label field...');
      await tester.enterText(find.byType(TextFormField).first, '');

      print('🔘 Tapping update button...');
      await tester.tap(find.text('Update Address'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter an address label'), findsOneWidget);

      print('✅ Validation test passed');
    });
  });

  print('\n🎉 All EditAddressScreen Tests Completed!\n');
}
