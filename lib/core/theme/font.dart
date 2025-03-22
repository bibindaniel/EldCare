import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';

class AppFonts {
  static const String _fontFamily = 'Poppins';

  static const TextStyle headline1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: kTextColor,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: kTextColor,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: kTextColor,
  );

  static const TextStyle headline4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: kTextColor,
  );

  static const TextStyle headline5 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: kTextColor,
  );

  static const TextStyle headline6 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: kTextColor,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: kTextColor,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: kTextColor,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: kWhiteColor,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: kSecondaryTextColor,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: kSecondaryTextColor,
    letterSpacing: 1.5,
  );

  // Light variants
  static TextStyle headline1Light = headline1.copyWith(color: kWhiteColor);
  static TextStyle headline2Light = headline2.copyWith(color: kWhiteColor);
  static TextStyle headline3Light = headline3.copyWith(color: kWhiteColor);
  static TextStyle headline4Light = headline4.copyWith(color: kWhiteColor);
  static TextStyle headline5Light = headline5.copyWith(color: kWhiteColor);
  static TextStyle headline6Light = headline6.copyWith(color: kWhiteColor);
  static TextStyle bodyText1Light = bodyText1.copyWith(color: kWhiteColor);
  static TextStyle bodyText2Light = bodyText2.copyWith(color: kWhiteColor);

  // Colored variants
  static TextStyle headline1Colored = headline1.copyWith(color: kPrimaryColor);
  static TextStyle headline2Colored = headline2.copyWith(color: kPrimaryColor);
  static TextStyle headline3Colored = headline3.copyWith(color: kPrimaryColor);
  static TextStyle headline4Colored = headline4.copyWith(color: kPrimaryColor);
  static TextStyle headline5Colored = headline5.copyWith(color: kPrimaryColor);
  static TextStyle headline6Colored = headline6.copyWith(color: kPrimaryColor);
  static TextStyle bodyText1Colored = bodyText1.copyWith(color: kPrimaryColor);
  static TextStyle bodyText2Colored = bodyText2.copyWith(color: kPrimaryColor);

  // Additional styles
  static const TextStyle cardTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: kTextColor,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: kSecondaryTextColor,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: kWhiteColor,
  );

  // Text styles for headings
  static const TextStyle kHeading1Style = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: kTextColor,
  );

  static const TextStyle kHeading2Style = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: kTextColor,
  );

  static const TextStyle kHeading3Style = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: kTextColor,
  );

  // Text style for body text
  static const TextStyle kBodyTextStyle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: kTextColor,
  );

  // Text style for small text
  static const TextStyle kSmallTextStyle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: kSecondaryTextColor,
  );
}
