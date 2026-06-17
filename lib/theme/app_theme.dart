
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF4CAF50), // A vibrant green
    scaffoldBackgroundColor: const Color(0xFFF5F5F5), // A light cream background
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xFF4CAF50),
      secondary: const Color(0xFFFFC107), // A warm accent color
      surface: Colors.white,
      onSurface: const Color(0xFF333333), // Darker text for readability
    ),
    appBarTheme: const AppBarTheme(
      color: Color(0xFFF5F5F5),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF333333)),
      titleTextStyle: TextStyle(
        color: Color(0xFF333333),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF555555),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Colors.white,
      elevation: 8,
      shape: CircularNotchedRectangle(),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent, // transparent to show BottomAppBar color
      selectedItemColor: Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF4CAF50),
    )
  );
}
