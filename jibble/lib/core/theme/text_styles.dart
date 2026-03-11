import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Brand Font: Dancing Script
  static TextStyle get brandTitle =>
      GoogleFonts.dancingScript(fontSize: 48, fontWeight: FontWeight.bold);

  static TextStyle get brandTitleSmall =>
      GoogleFonts.dancingScript(fontSize: 32, fontWeight: FontWeight.bold);

  // Default Inter Headings
  static TextStyle get heading1 =>
      GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold);

  static TextStyle get bodyText =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal);

  static TextStyle get caption =>
      GoogleFonts.inter(fontSize: 12, color: Colors.grey);
}
