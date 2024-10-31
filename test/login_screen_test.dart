import 'package:bloc_test/bloc_test.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_event.dart';
import 'package:eldcare/auth/presentation/blocs/auth/auth_state.dart';
import 'package:eldcare/auth/presentation/screens/login%20&%20singup/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthBloc mockAuthBloc;
  setUpAll(() {
    print('🚀 Starting LoginScreen test suite');
  });
  setUp(() {
    print('\n📝 Setting up individual test');
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    print('✅ MockAuthBloc initialized');
  });
  Widget createWidgetUnderTest() {
    print('🔨 Creating widget under test');
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('submits form with correct data', (WidgetTester tester) async {
      print('\n🧪 TEST: submits form with correct data');

      // Set a larger window size for testing
      print('📱 Setting test window size');
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Arrange
      print('🎯 Arranging test components');
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Verify initial widget state
      print('🔍 Verifying initial widget state');
      expect(find.byType(LoginScreen), findsOneWidget,
          reason: 'LoginScreen should be present');

      // Find form fields
      print('🔎 Finding form fields');
      final emailField = find.byKey(const ValueKey('emailField'));
      final passwordField = find.byKey(const ValueKey('passwordField'));
      final loginButton = find.byKey(const ValueKey('loginButton'));

      expect(emailField, findsOneWidget,
          reason: 'Email field should be present');
      expect(passwordField, findsOneWidget,
          reason: 'Password field should be present');
      expect(loginButton, findsOneWidget,
          reason: 'Login button should be present');

      // Scroll to make sure the button is visible
      print('📜 Scrolling to login button');
      await tester.ensureVisible(loginButton);
      await tester.pumpAndSettle();

      // Enter text
      print('⌨️ Entering test credentials');
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();
      print('✉️ Email entered: test@example.com');

      await tester.enterText(passwordField, 'password123');
      await tester.pump();
      print('🔑 Password entered: password123');

      // Tap login button
      print('👆 Tapping login button');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert
      print('✅ Verifying login event');
      verify(
        () => mockAuthBloc.add(
          const LoginEvent(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
      ).called(1);
      print('✨ Login event verified successfully');

      // Reset the window size
      addTearDown(() {
        print('🧹 Cleaning up test environment');
        tester.binding.window.clearPhysicalSizeTestValue();
      });
    });

    testWidgets('shows error message when login fails',
        (WidgetTester tester) async {
      print('\n🧪 TEST: shows error message when login fails');

      // Set a larger window size for testing
      print('📱 Setting test window size');
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Arrange
      const errorMessage = 'Invalid credentials';
      print('⚠️ Setting up error scenario with message: $errorMessage');

      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          AuthInitial(),
          const AuthError(errorMessage),
        ]),
      );
      print('✅ Mock stream configured');

      // Act
      print('🎬 Executing test actions');
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      print('🔍 Verifying error display');
      expect(find.byType(SnackBar), findsOneWidget,
          reason: 'SnackBar should be visible');
      expect(find.text(errorMessage), findsOneWidget,
          reason: 'Error message should be displayed');

      print('✅ Error message verified successfully');

      // Verify the state transition
      verify(() => mockAuthBloc.stream).called(greaterThan(0));
      print('✨ State transition verified');

      // Reset the window size
      addTearDown(() {
        print('🧹 Cleaning up test environment');
        tester.binding.window.clearPhysicalSizeTestValue();
      });
    });
  });
  tearDownAll(() {
    print('\n🏁 Completed all LoginScreen tests');
  });
}
