import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Update Shop Page', () {
    late FlutterDriver driver;

    // Connect to the Flutter driver before running any tests
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed
    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
      }
    });

    test('update shop name', () async {
      // Find the shop name field
      final shopNameField = find.byValueKey('shop_name_field');
      await driver.tap(shopNameField);
      await driver.enterText('Updated Shop Name');

      // Find the submit button
      final submitButton = find.byValueKey('submit_button');
      await driver.tap(submitButton);

      // Verify that the shop was updated successfully
      final successMessage = find.text('Shop updated successfully');
      expect(await driver.getText(successMessage), 'Shop updated successfully');
    });
  });
}
