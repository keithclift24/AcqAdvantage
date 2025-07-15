import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1A202C),
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
);
