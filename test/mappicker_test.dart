// import 'package:eldcare/pharmacy/presentation/shop/mappicker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// void main() {
//   setUp(() {
//     print('\n=== Starting new test ===');
//   });

//   tearDown(() {
//     print('=== Test completed ===\n');
//   });

//   Widget createMapPickerScreen() {
//     const initialLocation = LatLng(37.7749, -122.4194);
//     print('Creating MapPickerScreen with initial location: $initialLocation');
//     return const MaterialApp(
//       home: MapPickerScreen(initialLocation: initialLocation),
//     );
//   }

//   testWidgets('MapPickerScreen UI elements test', (WidgetTester tester) async {
//     print('Running UI elements test...');

//     // Build our app and trigger a frame.
//     await tester.pumpWidget(createMapPickerScreen());
//     print('Widget tree built successfully');

//     // Verify that the AppBar title is correct
//     final titleFinder = find.text('Select Location');
//     print('Checking for AppBar title...');
//     expect(titleFinder, findsOneWidget);
//     print('✓ AppBar title found');

//     // Verify that the Select button exists
//     final buttonFinder = find.text('Select');
//     print('Checking for Select button...');
//     expect(buttonFinder, findsOneWidget);
//     print('✓ Select button found');

//     // Verify that GoogleMap widget is present
//     print('Checking for GoogleMap widget...');
//     expect(find.byType(GoogleMap), findsOneWidget);
//     print('✓ GoogleMap widget found');
//   });

//   testWidgets('Select button returns null when no marker is selected',
//       (WidgetTester tester) async {
//     print('Running Select button test...');
//     LatLng? result;

//     await tester.pumpWidget(MaterialApp(
//       home: Builder(
//         builder: (context) => ElevatedButton(
//           onPressed: () async {
//             print('Opening map picker...');
//             result = await Navigator.push<LatLng>(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const MapPickerScreen(
//                   initialLocation: LatLng(37.7749, -122.4194),
//                 ),
//               ),
//             );
//             print('Map picker returned: $result');
//           },
//           child: const Text('Open Map'),
//         ),
//       ),
//     ));
//     print('Initial widget tree built');

//     // Open the map
//     print('Tapping Open Map button...');
//     await tester.tap(find.text('Open Map'));
//     await tester.pumpAndSettle();
//     print('Map opened successfully');

//     // Tap the select button
//     print('Tapping Select button...');
//     await tester.tap(find.text('Select'));
//     await tester.pumpAndSettle();
//     print('Select button tapped');

//     // Verify that no location was returned
//     print('Verifying result...');
//     expect(result, null);
//     print('✓ Verified: result is null as expected');
//   });

//   test('Simple location validation test', () {
//     print('Running location validation test...');

//     const location = LatLng(37.7749, -122.4194);
//     print('Testing location: $location');

//     expect(location.latitude, 37.7749);
//     print('✓ Latitude verified');

//     expect(location.longitude, -122.4194);
//     print('✓ Longitude verified');
//   });
// }
