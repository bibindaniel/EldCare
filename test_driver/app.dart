import 'package:flutter_driver/driver_extension.dart';
import 'package:eldcare/main.dart' as app;

void main() {
  // Enable Flutter Driver extension
  enableFlutterDriverExtension();

  // Call the `main()` function of the app, or call `runApp` with
  // any widget you are interested in testing.
  app.main();
}
