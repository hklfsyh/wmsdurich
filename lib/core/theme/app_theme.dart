import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    // Palet Warna Utama
    primaryColor: AppColors.primary,

    // Warna Latar Belakang
    scaffoldBackgroundColor: AppColors.background,

    // App Bar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0, // App Bar tanpa bayangan (flat design)
      centerTitle: true,
    ),

    // Input Fields (TextFormField)
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.cardBackground,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      hintStyle: TextStyle(color: AppColors.textSecondary),
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
    ),

    // Tombol (Contoh: Tombol Login/Simpan yang Hitam)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // Warna Hitam Solid
        foregroundColor: AppColors.background, // Teks Putih
        minimumSize: const Size(double.infinity, 50), // Lebar penuh
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),

    // Tambahkan style Text, Card, dan lain-lain di sini
  );
}
