import 'package:flutter/material.dart';

// 1. Warna Dasar Aplikasi
class AppColors {
  // Primary (Aksen utama, misalnya untuk tombol utama/login)
  static const Color primary =
      Color(0xFF000000); // Hitam Solid (sesuai tombol Login/Simpan)

  // Secondary (Mungkin untuk ikon atau teks aksen)
  static const Color secondary = Color(0xFF5A5A5A); // Abu-abu gelap

  // Background dan Card
  static const Color background = Color(0xFFFFFFFF); // Putih
  static const Color cardBackground =
      Color(0xFFF7F7F7); // Abu-abu sangat terang (untuk background card/input)

  // Text
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF5A5A5A);

  // 2. Warna Status (Sesuai Halaman Warehouse)
  static const Color statusSuccess = Color(0xFF4CAF50); // Hijau (untuk 'Bagus')
  static const Color statusWarning =
      Color(0xFFFFC107); // Kuning/Oranye (untuk 'Hilang')
  static const Color statusDanger =
      Color(0xFFF44336); // Merah (untuk 'Busuk'/'Hancur')

  // 3. Warna Aksi
  static const Color actionDelete =
      Color(0xFFD32F2F); // Merah untuk tombol Hapus
  static const Color actionEdit = Color(0xFF1976D2); // Biru untuk tombol Edit
}
