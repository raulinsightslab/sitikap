import 'package:flutter/material.dart';
import 'package:sitikap/extensions/extensions.dart';
import 'package:sitikap/utils/colors.dart';
import 'package:sitikap/views/login_screen.dart';
import 'package:sitikap/views/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  static const id = "/onboarding_screen";

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/poto_gedung.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay warna biar teks lebih jelas
          Container(color: AppColors.primaryDarkBlue.withOpacity(0.7)),

          // Konten Utama
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  CircleAvatar(
                    radius: 50,
                    child: Image.asset(
                      "assets/images/ppkd_logo1.png",
                      height: 90,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Judul
                  const Text(
                    "SiTiKAP",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutralWhite,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    "Absensi Digital PPKD Jakarta Pusat",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.neutralWhite.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Tombol Login
                  // Tombol Login dengan Gradient
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.buttonGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          context.push(const LoginScreen());
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: AppColors.neutralWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Tombol Register
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.neutralWhite),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        context.push(LoginScreen());
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: AppColors.neutralWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Footer
                  const Text(
                    "v1.0 • Powered by PPKD",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
