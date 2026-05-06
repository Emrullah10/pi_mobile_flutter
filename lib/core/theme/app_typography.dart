import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Whisper Pi Summary Hub — Typography System
/// Dual-font: Space Grotesk (headlines/labels) + Inter (body)
class AppTypography {
  AppTypography._();

  // ─── Headlines (Space Grotesk) ───

  static TextStyle h1 = GoogleFonts.spaceGrotesk(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.02 * 48,
  );

  static TextStyle h2 = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.01 * 32,
  );

  static TextStyle h3 = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ─── Body (Inter) ───

  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ─── Label (Space Grotesk — Caps/Technical) ───

  static TextStyle labelCaps = GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.1 * 12,
  );

  static TextStyle labelSm = GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
  );

  // ─── Monospace (Timestamps, technical readout) ───

  static TextStyle mono = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle monoLg = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
}
