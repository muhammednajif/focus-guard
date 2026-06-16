import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgPrimary = Color(0xFFEDEAE0);
  static const Color bgSecondary = Color(0xFFE3DFD3);
  static const Color textPrimary = Color(0xFF3C3935);
  static const Color accent = Color(0xFF97A97C);
  static const Color surfaceGlass = Color(0xB3EDEAE0);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: bgPrimary,
      primaryColor: accent,
      fontFamily: 'Outfit',
      appBarTheme: const AppBarTheme(
        backgroundColor: bgPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgSecondary,
        selectedItemColor: accent,
        unselectedItemColor: Colors.grey,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accent),
    );
  }
}
