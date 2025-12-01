import 'package:flutter/material.dart';

class AppTheme {
  // Premium Color Palette
  static const Color primaryPurple = Color(0xFF6C63FF);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color accentPink = Color(0xFFFF6584);
  static const Color backgroundDark = Color(0xFF0F0F1E);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF2A2A4E);
  
  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, secondaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      backgroundDark,
      surfaceDark,
      Color(0xFF6C63FF),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // Glass Effect for Cards
  static BoxDecoration glassCard({
    double opacity = 0.1,
    double borderOpacity = 0.2,
    double borderWidth = 1.5,
    double borderRadius = 24,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(opacity),
          Colors.white.withOpacity(opacity / 2),
        ],
      ),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
  
  // Premium Button Decoration
  static BoxDecoration premiumButton({
    List<Color>? gradientColors,
    double borderRadius = 20,
    Color? shadowColor,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors ?? [primaryPurple, secondaryGreen],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: (shadowColor ?? primaryPurple).withOpacity(0.5),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
  
  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.3,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );
  
  static TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: Colors.white.withOpacity(0.8),
    height: 1.5,
  );
  
  static TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.white.withOpacity(0.6),
    height: 1.3,
  );
  
  // Input Decoration
  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: primaryPurple) : null,
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      filled: true,
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cardDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentPink, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}
