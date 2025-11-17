import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // 1. Palet Warna Utama & Font
    // Gunakan GoogleFonts.interTextTheme untuk menerapkan font ke seluruh Theme
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    primaryColor: AppColors.primary,

    // fontFamily: 'Inter',

    // 2. Background
    scaffoldBackgroundColor: AppColors.background, // F9FAFB

    // 3. App Bar
    appBarTheme: AppBarTheme(
      // Hapus const karena kita menggunakan GoogleFonts
      backgroundColor: AppColors.background, // F9FAFB
      foregroundColor: AppColors.textPrimary, // Hitam
      elevation: 0,
      centerTitle: true,
      // Gunakan GoogleFonts.inter() secara eksplisit
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    ),

    // 4. Input Fields (TextFormField)
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.fieldBackground, // ECECF0
      filled: true,
      // Gunakan GoogleFonts.inter() untuk hintStyle
      hintStyle: GoogleFonts.inter(
        color: AppColors.textPlaceholder, // 898989
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none, // Tidak ada border yang terlihat
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    ),

    // 5. Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textPlaceholder,
      elevation: 8,
    ),

    // 6. Tombol (ElevatedButton - Tombol Hitam Solid)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // Hitam Solid (000000)
        foregroundColor: AppColors.white, // Teks Putih
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        // Gunakan GoogleFonts.inter() untuk textStyle
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),

    // 7. Card Theme (Untuk Card View di Home/Warehouse)
    cardTheme: CardTheme(
      color: AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
    ),
  );
}
