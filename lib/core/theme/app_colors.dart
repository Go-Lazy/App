import 'package:flutter/material.dart';

/// Centralized GoLazy color palette. All widgets should reference these
/// constants instead of hardcoding colors, so the brand palette can evolve
/// from a single source of truth.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFFF9701D);
  static const Color primaryDark = Color(0xFFE85F0A);
  static const Color primarySurface = Color(0xFFFFF1E6);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF7F7F8);

  /// Vehicle names, headings, nav labels, prices, location — anything that
  /// is the main point of a line of text.
  static const Color textPrimary = Color(0xFF111111);

  /// Genuinely secondary but still legible information: distances, rating
  /// counts, "From ₹80/hr", supporting descriptions.
  static const Color textSecondary = Color(0xFF4B5563);

  /// Lowest-emphasis supporting text, reserved for content that should
  /// visually recede behind both primary and secondary text.
  static const Color textMuted = Color(0xFF6B7280);

  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE7E7EA);

  static const Color success = Color(0xFF1FA24A);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFE23D3D);
  static const Color rating = Color(0xFFF5A623);
}
