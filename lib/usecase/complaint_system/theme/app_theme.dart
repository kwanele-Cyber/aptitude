import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryPurple = Color(0xFF6B21A8);
  static const Color lightPurple = Color(0xFF9333EA);
  static const Color accentPurple = Color(0xFFD8B4FE);
  static const Color darkPurple = Color(0xFF4C1D95);
  static const Color pendingColor = Color(0xFFF59E0B);
  static const Color reviewingColor = Color(0xFF3B82F6);
  static const Color resolvedColor = Color(0xFF10B981);
  static const Color dismissedColor = Color(0xFF6B7280);
  static const Color flaggedColor = Color(0xFFEF4444);
  static const Color bannedColor = Color(0xFF7F1D1D);
  static const Color bgDark = Color(0xFF0F0A1E);
  static const Color bgCard = Color(0xFF1A1033);
  static const Color bgCardLight = Color(0xFF241547);
  static const Color textPrimary = Color(0xFFF3E8FF);
  static const Color textSecondary = Color(0xFFBB98E8);
  static const Color dividerColor = Color(0xFF3D2B6B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: lightPurple,
        surface: bgCard,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w800),
          displayMedium: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w700),
          titleLarge: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w600),
          titleMedium: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          labelLarge: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
              color: dividerColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: lightPurple, width: 2),
        ),
        labelStyle:
            const TextStyle(color: textSecondary),
        hintStyle:
            const TextStyle(color: textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgCardLight,
        selectedColor: primaryPurple,
        labelStyle: GoogleFonts.spaceGrotesk(
            color: textPrimary, fontSize: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: dividerColor),
      ),
      dividerTheme: const DividerThemeData(
          color: dividerColor, thickness: 1),
      bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: lightPurple,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pendingColor;
      case 'reviewing':
        return reviewingColor;
      case 'resolved':
        return resolvedColor;
      case 'dismissed':
        return dismissedColor;
      case 'flagged':
        return flaggedColor;
      case 'banned':
        return bannedColor;
      default:
        return textSecondary;
    }
  }

  static IconData statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'reviewing':
        return Icons.manage_search_rounded;
      case 'resolved':
        return Icons.check_circle_rounded;
      case 'dismissed':
        return Icons.cancel_rounded;
      case 'flagged':
        return Icons.flag_rounded;
      case 'banned':
        return Icons.block_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}