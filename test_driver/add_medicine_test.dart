// import 'package:flutter_driver/flutter_driver.dart';
// import 'package:test/test.dart';

// void main() {
//   group('Add Medicine Page', () {
//     late FlutterDriver driver;

//     // Connect to the Flutter driver before running any tests
//     setUpAll(() async {
//       driver = await FlutterDriver.connect();
//     });

//     // Close the connection to the driver after the tests have completed
//     tearDownAll(() async {
//       await driver.close();
//     });

//     test('add new medicine', () async {
//       // Find the medicine name field
//       final medicineNameField = find.byValueKey('medicine_name_field');
//       await driver.tap(medicineNameField);
//       await driver.enterText('Test Medicine');

//       // Find the quantity field
//       final quantityField = find.byValueKey('quantity_field');
//       await driver.tap(quantityField);
//       await driver.enterText('10');

//       // Find the start date field
//       final startDateField = find.byValueKey('start_date_field');
//       await driver.tap(startDateField);
//       await driver.enterText('2023-01-01');

//       // Find the end date field
//       final endDateField = find.byValueKey('end_date_field');
//       await driver.tap(endDateField);
//       await driver.enterText('2023-12-31');

//       // Find the shape selector
//       final shapeSelector = find.byValueKey('shape_selector');
//       await driver.tap(shapeSelector);

//       // Find the color selector
//       final colorSelector = find.byValueKey('color_selector');
//       await driver.tap(colorSelector);

//       // Find the frequency field
//       final frequencyField = find.byValueKey('frequency_field');
//       await driver.tap(frequencyField);
//       await driver.enterText('2');

//       // Find the submit button
//       final submitButton = find.byValueKey('submit_button');
//       await driver.tap(submitButton);

//       // Verify that the medicine was added successfully
//       final successMessage = find.text('Medicine added successfully');
//       expect(
//           await driver.getText(successMessage), 'Medicine added successfully');
//     });
//   });
// }
