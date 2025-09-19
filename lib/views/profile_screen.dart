import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sitikap/extensions/extensions.dart';
import 'package:sitikap/local/shared_preferenced.dart';
import 'package:sitikap/utils/colors.dart';
import 'package:sitikap/views/onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const id = "/profile_screen";

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userToken;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final token = await PreferenceHandler.getToken();
      final isLoggedIn = await PreferenceHandler.getLogin();

      setState(() {
        _userToken = token;
        _isLoggedIn = isLoggedIn ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Anda yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                context.pop();
                await _performLogout();
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: AppColors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Hapus data login dari shared preferences
      await PreferenceHandler.removeLogin();
      await PreferenceHandler.removeToken();

      // Navigasi ke login screen menggunakan context extension
      context.pushNamedAndRemoveUntil(OnboardingScreen.id, (route) => false);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      context.showSnackBar("Logout gagal: $e");
    }
  }

  void _showComingSoon() {
    context.showSnackBar("Fitur akan segera hadir!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text(
      //     "Profile",
      //     style: GoogleFonts.poppins(
      //       fontWeight: FontWeight.bold,
      //       color: AppColors.primaryDarkBlue,
      //     ),
      //   ),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   centerTitle: true,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.black),
      //     onPressed: () => context.pop(),
      //   ),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Data Diri",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDarkBlue,
              ),
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profile Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDarkBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Profile Photo
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.primaryDarkBlue,
                                child: const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // User Name (dari token atau default)
                              Text(
                                _userToken != null
                                    ? "Pengguna Terautentikasi"
                                    : "Guest",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDarkBlue,
                                ),
                              ),

                              // Status Login
                              Text(
                                _isLoggedIn ? "Status: Login" : "Status: Guest",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                ),
                              ),

                              // Token (debug info)
                              if (_userToken != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "Token: ${_userToken!.substring(0, 20)}...",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Menu Options
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // Edit Profile
                              _buildMenuOption(
                                icon: Icons.edit,
                                title: "Edit Profile",
                                onTap: _showComingSoon,
                              ),

                              const Divider(height: 1),

                              // Pengaturan
                              _buildMenuOption(
                                icon: Icons.settings,
                                title: "Pengaturan",
                                onTap: _showComingSoon,
                              ),

                              const Divider(height: 1),

                              // Tentang Aplikasi
                              _buildMenuOption(
                                icon: Icons.info_outline,
                                title: "Tentang Aplikasi",
                                onTap: _showComingSoon,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Logout Button (hanya tampil jika login)
                        if (_isLoggedIn)
                          // SizedBox(
                          //   width: double.infinity,
                          //   height: 50,
                          //   child: ElevatedButton(
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: Colors.red,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(12),
                          //       ),
                          //     ),
                          //     onPressed: _logout,
                          //     child: Text(
                          //       "Logout",
                          //       style: GoogleFonts.poppins(
                          //         color: Colors.white,
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.w600,
                          //       ),
                          //     ),
                          //   ),
                          // ),
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
                                onPressed: () {
                                  _logout();
                                },
                                child: const Text(
                                  "Keluar akun",
                                  style: TextStyle(
                                    color: AppColors.neutralWhite,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // App Version
                        Text(
                          "SiTIKAP v1.0",
                          style: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryDarkBlue),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: AppColors.primaryDarkBlue,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

extension on BuildContext {
  void showSnackBar(String s) {}
}
