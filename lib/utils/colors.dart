import 'package:flutter/material.dart';

class AppColors {
  // Warna Utama
  static const Color primaryDarkBlue = Color(0xFF1B2A42);
  static const Color blue = Color(0xFF0D47A1);

  // Warna Sekunder
  static const Color secondaryBlue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFFBBDEFB);

  // Warna Aksen (Gradient)
  static const Color accentLightBlue = Color(0xFF87CEEB);
  static const Color accentGreen = Color(0xFF90EE90);

  // Warna Netral (Untuk Latar Belakang Terang)
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralLightGray = Color(0xFFF5F5F5);
  static const Color neutralGray = Color(0xFF9E9E9E);
  static const Color neutralDarkGray = Color(0xFF616161);

  // Warna Status
  static const Color statusSuccess = Color(0xFF4CAF50);
  static const Color statusWarning = Color(0xFFFF9800);
  static const Color statusError = Color(0xFFF44336);
  static const Color statusInfo = Color(0xFF2196F3);

  // Warna Tambahan
  static const Color shadowColor = Color(0x1A000000);
  static const Color overlayColor = Color(
    0x661B2A42,
  ); // Dark blue dengan opacity

  // Fungsi untuk membuat gradien
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [accentLightBlue, accentGreen],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [primaryDarkBlue, blue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient gradienbiru = LinearGradient(
    colors: [Colors.blue, AppColors.blue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
