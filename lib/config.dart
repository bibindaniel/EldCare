import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get razorpayKey => dotenv.env['RAZORPAY_KEY'] ?? '';
}
