import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color background = Color(0xFFEFF6F5); // Soft pastel mint background
  static const Color surface = Color(0xFFFFFFFF);
  
  // Brand Colors
  static const Color primary = Color(0xFF68D3BA); // Primary Mint
  static const Color secondary = Color(0xFFFF7A64); // Coral
  static const Color tertiary = Color(0xFFFFC857); // Yellow
  
  // Text Colors
  static const Color textPrimary = Color(0xFF333333); // Dark Grey
  static const Color textSecondary = Color(0xFF888888); // Softer Grey
  
  // Functional Colors
  static const Color success = Color(0xFF68D3BA); // Using Mint for success
  static const Color warning = Color(0xFFFFC857); // Using Yellow for warning
  static const Color error = Color(0xFFFF7A64); // Using Coral for error/action

  // Typography
  static TextTheme get _textTheme => TextTheme(
        // Headlines - Poppins Rounded Bold
        headlineLarge: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        
        // Titles - Poppins
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        
        // Body - Nunito Medium
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        
        // Labels
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        surface: surface,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        error: error,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      
      fontFamily: GoogleFonts.nunito().fontFamily,
      textTheme: _textTheme,
      
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: _textTheme.headlineSmall,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Softer, more rounded
          ),
          textStyle: _textTheme.labelLarge?.copyWith(fontSize: 16),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(color: primary, fontSize: 16),
        ),
      ),
      
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0, // Flat style as per illustration
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        margin: const EdgeInsets.only(bottom: 16),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black12, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: _textTheme.bodyMedium?.copyWith(color: textSecondary),
        labelStyle: _textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),
      
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
    );
  }
}
