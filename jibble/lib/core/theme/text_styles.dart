import 'package:flutter/material.dart';

class AppTextStyles {
  // Add GoogleFonts if you have it in pubspec, otherwise use default
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}
