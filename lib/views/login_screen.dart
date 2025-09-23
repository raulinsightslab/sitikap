import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sitikap/api/users_api.dart';
import 'package:sitikap/extensions/extensions.dart';
import 'package:sitikap/local/shared_preferenced.dart';
import 'package:sitikap/models/users/register_model.dart';
import 'package:sitikap/utils/colors.dart';
import 'package:sitikap/views/lupa_pw_screen.dart';
import 'package:sitikap/views/register_screen.dart';
import 'package:sitikap/widget/botnav.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const id = "/login_screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;
  RegisterUserModel? user;
  String? errorMessage;

  // Helper method for safe setState
  void safeSetState(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }

  void showSuccessLottie(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 1300), () {
          if (mounted) {
            Navigator.of(context).pop();
            context.pushReplacement(const Botnav());
          }
        });
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: 400,

            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset("assets/lottie/login_succes.json", height: 200),
                const SizedBox(height: 10),
                Text(
                  "Login Berhasil 🎉",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void loginUser() async {
    safeSetState(() {
      isLoading = true;
      errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email dan Kata Sandi tidak boleh kosong"),
          ),
        );
      }
      safeSetState(() => isLoading = false);
      return;
    }

    try {
      final results = await AuthenticationAPI.loginUser(
        email: email,
        password: password,
      );

      safeSetState(() {
        user = results;
      });

      await PreferenceHandler.saveToken(user?.data?.token.toString() ?? "");

      if (mounted) {
        showSuccessLottie(context);
      }
      print(user?.toJson());
    } catch (e) {
      print(e);
      safeSetState(() {
        errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage.toString())));
      }
    } finally {
      safeSetState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(backgroundColor: AppColors.neutralWhite),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Selamat Datang Kembali 👋",
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    "Masuk untuk melanjutkan ke SiTIKAP",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
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
                ),
                const SizedBox(height: 16),

                // TextField Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Kata Sandi",
                    hintText: "Masukkan Kata Sandi Akun Anda",
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
                        safeSetState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.neutralLightGray,
                  ),
                ),
                const SizedBox(height: 16),

                // Link Lupa Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      context.push(const LupapwScreen());
                    },
                    child: Text(
                      "Lupa Password?",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDarkBlue.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol Login dengan Gradient
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          // Color.fromARGB(255, 58, 75, 101),
                          Colors.blue,
                          AppColors.blue,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
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
                      onPressed: isLoading ? null : loginUser,
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
                const SizedBox(height: 20),

                // Link ke Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Belum punya akun?",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        context.push(const RegisterScreen());
                      },
                      child: Text(
                        "Daftar sekarang",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
