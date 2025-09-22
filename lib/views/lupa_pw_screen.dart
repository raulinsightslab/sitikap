// lupapw_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sitikap/api/users_api.dart';
import 'package:sitikap/utils/colors.dart';
import 'package:sitikap/views/reset_pw_screen.dart';

class LupapwScreen extends StatefulWidget {
  const LupapwScreen({super.key});
  static const id = "/lupapw_screen";

  @override
  State<LupapwScreen> createState() => _LupapwScreenState();
}

class _LupapwScreenState extends State<LupapwScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> sendOtp() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email tidak boleh kosong")));
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await AuthenticationAPI.forgotPassword(email);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));

      // Navigate to OTP verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(email: email),
        ),
      );
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
          "Lupa Password",
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
                // Judul
                Text(
                  "Lupa Password?",
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Masukkan email Anda yang terdaftar. Kami akan mengirimkan OTP untuk mereset password.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),

                // TextField Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Masukkan Email Anda",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.neutralLightGray,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 30),

                // Tombol Kirim OTP
                SizedBox(
                  width: double.infinity,
                  height: 52,
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
                      onPressed: isLoading ? null : sendOtp,
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
                              "Kirim OTP",
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
