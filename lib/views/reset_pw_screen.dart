// reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sitikap/api/users_api.dart';
import 'package:sitikap/utils/colors.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  String? errorMessage;

  Future<void> resetPassword() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final otp = _otpController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (otp.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field harus diisi")));
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password dan konfirmasi password tidak cocok"),
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await AuthenticationAPI.resetPassword(
        email: widget.email,
        otp: otp,
        password: password,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));

      // Kembali ke login screen
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.neutralWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDarkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Reset Password",
          style: GoogleFonts.poppins(
            color: AppColors.primaryDarkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informasi Email
                Text(
                  "Reset Password untuk:",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  widget.email,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 30),

                // TextField OTP
                TextFormField(
                  controller: _otpController,
                  decoration: InputDecoration(
                    labelText: "Kode OTP",
                    hintText: "Masukkan 6 digit OTP",
                    prefixIcon: const Icon(Icons.sms),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.neutralLightGray,
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                const SizedBox(height: 16),

                // TextField Password Baru
                TextFormField(
                  controller: _passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password Baru",
                    hintText: "Masukkan password baru",
                    prefixIcon: const Icon(Icons.lock),
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
                const SizedBox(height: 16),

                // TextField Konfirmasi Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "Konfirmasi Password Baru",
                    hintText: "Konfirmasi password baru",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.neutralLightGray,
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol Reset Password
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.gradienbiru,
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
                      onPressed: isLoading ? null : resetPassword,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.neutralWhite,
                                ),
                              ),
                            )
                          : const Text(
                              "Reset Password",
                              style: TextStyle(
                                color: AppColors.neutralWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
