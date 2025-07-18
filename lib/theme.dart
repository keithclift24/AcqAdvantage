import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1A202C),
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 238, 67, 67), // Cyan blue from your theme
    secondary: Color.fromARGB(255, 223, 182, 121), // Red from your theme
    surface: Color(0xFF1A202C), // Background color
  ),
  textTheme: GoogleFonts.montserratTextTheme(
    ThemeData.dark().textTheme,
  ),
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFE53E3E)),
      borderRadius: BorderRadius.circular(8.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFE53E3E)),
      borderRadius: BorderRadius.circular(8.0),
    ),
    labelStyle: const TextStyle(color: Colors.black54),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF00B5D8),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1A202C), // Match your background
    selectedItemColor: Color(0xFF00B5D8), // Cyan blue for selected
    unselectedItemColor: Colors.white70, // Light but readable for unselected
    type: BottomNavigationBarType.fixed,
  ),
);
