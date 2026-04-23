import 'package:flutter/material.dart';

class AppTheme {
  static const primaryRed = Color(0xFFE50914);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primaryRed,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryRed,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),

    scaffoldBackgroundColor: Colors.white,
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primaryRed,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: primaryRed,
      centerTitle: true,
    ),
    scaffoldBackgroundColor: Colors.black,
  );
}
