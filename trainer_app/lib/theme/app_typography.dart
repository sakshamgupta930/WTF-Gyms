import 'package:flutter/material.dart';

class AppTypography {
  static const TextStyle h1 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600, // Semi-bold for titles
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600, // Semi-bold for titles
    letterSpacing: -0.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal, // Regular for body
    letterSpacing: 0.1,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal, // Regular for body
    letterSpacing: 0.1,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
  );
}
