import 'package:flutter/material.dart';
import 'package:sitikap/extensions/extensions.dart';
import 'package:sitikap/utils/colors.dart';
import 'package:sitikap/views/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const id = "/login_screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset("assets/images/ppkd_logo1.png", height: 150),
                SizedBox(height: 20),
                // Judul Aplikasi
                Text(
                  "SiTIKAP",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(height: 40),

                // TextField Email / No Peserta
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Email / No. Peserta",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.neutralLightGray,
                  ),
                ),
                const SizedBox(height: 16),

                // TextField Password
                TextFormField(
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.neutralLightGray,
                  ),
                ),
                const SizedBox(height: 24),

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
                        // TODO: Implement login logic
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
                const SizedBox(height: 12),

                // Tombol Register
                GestureDetector(
                  onTap: () {
                    context.push(const RegisterScreen());
                  },
                  child: Text(
                    "Register",
                    style: TextStyle(
                      color: AppColors.accentLightBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
