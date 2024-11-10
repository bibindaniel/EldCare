// // test_driver/login_test.dart
// import 'package:flutter_driver/flutter_driver.dart';
// import 'package:test/test.dart';

// void main() {
//   group('Login Screen Tests', () {
//     late FlutterDriver driver;

//     setUpAll(() async {
//       // Connect to the Flutter driver before running the tests.
//       driver = await FlutterDriver.connect();
//     });

//     tearDownAll(() async {
//       // Close the driver after all tests have run.
//       if (driver != null) {
//         await driver.close();
//       }
//     });

//     test('Login with valid credentials', () async {
//       // Find the email and password fields and the login button.
//       SerializableFinder emailField = find.byValueKey('emailField');
//       SerializableFinder passwordField = find.byValueKey('passwordField');
//       SerializableFinder loginButton = find.byValueKey('loginButton');

//       // Enter valid email and password.
//       await driver.tap(emailField);
//       await driver.enterText('test@example.com');

//       await driver.tap(passwordField);
//       await driver.enterText('password123');

//       // Tap the login button.
//       await driver.tap(loginButton);

//       // Wait for the next screen to appear (you can adjust this based on your app's behavior).
//       await driver.waitFor(find.byType('UserRedirection'));
//     });

//     test('Show error message for invalid credentials', () async {
//       // Find the email and password fields and the login button.
//       SerializableFinder emailField = find.byValueKey('emailField');
//       SerializableFinder passwordField = find.byValueKey('passwordField');
//       SerializableFinder loginButton = find.byValueKey('loginButton');

//       // Enter invalid email and password.
//       await driver.tap(emailField);
//       await driver.enterText('invalid@example.com');

//       await driver.tap(passwordField);
//       await driver.enterText('wrongpassword');

//       // Tap the login button.
//       await driver.tap(loginButton);

//       // Wait for the error message to appear.
//       await driver.waitFor(find.text('Invalid email or password'));
//     });
//   });
// }
