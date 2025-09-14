import 'package:flutter/material.dart';

class AppColors {
  // Warna Utama
  static const Color primaryDarkBlue = Color(0xFF1B2A42);
  static const Color blue = Color(0xFF0D47A1);

  // Warna Aksen (Gradient)
  static const Color accentLightBlue = Color(0xFF87CEEB);
  static const Color accentGreen = Color(0xFF90EE90);

  // Warna Netral (Untuk Latar Belakang Terang)
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralLightGray = Color(0xFFF5F5F5);

  // Fungsi untuk membuat gradien
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [accentLightBlue, accentGreen],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
