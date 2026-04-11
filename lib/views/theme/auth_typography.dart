import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Refined pairing: [Playfair Display] for headlines, [Source Sans 3] for UI.
abstract final class AuthTypography {
  static TextStyle displayTitle(Color color) {
    return GoogleFonts.playfairDisplay(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      height: 1.08,
      letterSpacing: -0.4,
      color: color,
    );
  }

  static TextStyle subtitle(Color color) {
    return GoogleFonts.sourceSans3(
      fontSize: 15.5,
      height: 1.5,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle link(Color color) {
    return GoogleFonts.sourceSans3(
      fontSize: 15.5,
      height: 1.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.15,
      color: color,
    );
  }

  static TextStyle fieldText(Color color) {
    return GoogleFonts.sourceSans3(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.25,
      color: color,
    );
  }

  static TextStyle fieldHint(Color color) {
    return GoogleFonts.sourceSans3(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle pillButton() {
    return GoogleFonts.sourceSans3(
      color: Colors.white,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );
  }

  static TextStyle forgotCaps() {
    return GoogleFonts.sourceSans3(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.0,
      color: Colors.white,
    );
  }

  static TextStyle outlinedButton(Color color) {
    return GoogleFonts.sourceSans3(
      fontWeight: FontWeight.w700,
      fontSize: 15.5,
      letterSpacing: 0.2,
      color: color,
    );
  }

  static TextStyle textButtonLink(Color color) {
    return GoogleFonts.sourceSans3(
      color: color,
      fontWeight: FontWeight.w600,
      fontSize: 15,
      letterSpacing: 0.25,
    );
  }
}
