import 'package:flutter/material.dart';

class AppColors {
  // 1. Warna Dasar & Background (Sesuai List Anda)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Background & Field
  static const Color background = Color(0xFFF9FAFB); // Putih Background
  static const Color fieldBackground =
      Color(0xFFECECF0); // Abu-abu Field (untuk input)

  // Text & Placeholder
  static const Color textPlaceholder = Color(0xFF898989); // Abu-abu Placeholder
  static const Color textPrimary = black;
  static const Color textSecondary = textPlaceholder;

  // 2. Warna Primer & Aksi (Sesuai Tombol dan Aksen)
  static const Color primary =
      black; // Digunakan untuk tombol utama (Login, Tambah, Simpan)
  static const Color actionDelete =
      Color(0xFFE7000B); // Merah (untuk tombol Hapus)
  static const Color actionCancel = white; // Untuk tombol Batal

  // 3. Warna Status (Sesuai Home Page & Card View)
  // Hijau
  static const Color statusSuccessLight =
      Color(0xFFDBFCE7); // Hijau Muda (Background Card)
  static const Color statusSuccessDark =
      Color(0xFF008236); // Hijau Tua (Aksen/Teks)
  // Kuning/Emas
  static const Color statusWarningLight =
      Color(0xFFFEFCE8); // Kuning Muda (Background Card)
  static const Color statusWarningDark =
      Color(0xFFA65F00); // Kuning Tua (Aksen/Teks)
  // Merah/Rusak
  static const Color statusDangerLight =
      Color(0xFEF2F2); // Merah Muda (Background Card)
  static const Color statusDangerDark =
      Color(0xFFC10007); // Merah Tua (Aksen/Teks)

  // 4. Warna Aksen Lain (Sesuai List Anda)
  static const Color blueLight = Color(0xFFDBEAFE);
  static const Color blueDark = Color(0xFF155DFC);
  static const Color orangeLight = Color(0xFFFFF7ED);
  static const Color orangeDark = Color(0xFFCA3500);
  static const Color redSolid = Color(0xFFE7000B); // Merah #E7000B
}
