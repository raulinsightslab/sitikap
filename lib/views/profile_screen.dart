import 'package:flutter/material.dart';
import 'package:sitikap/extensions/extensions.dart';
import 'package:sitikap/utils/colors.dart';
import 'package:sitikap/views/login_screen.dart'; // pastikan path sesuai

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const id = "/profile_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.neutralWhite,
                child: Icon(
                  Icons.person,
                  size: 60,
                  // color: AppColors.primaryDarkBlue,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Raul Akbar",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutralWhite,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "raulakbar@example.com",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.neutralLightGray,
                ),
              ),
              const SizedBox(height: 30),

              // Card Menu
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.neutralWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMenuItem(
                        icon: Icons.edit,
                        title: "Edit Profile",
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.settings,
                        title: "Pengaturan",
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.info,
                        title: "Tentang Aplikasi",
                        onTap: () {},
                      ),
                      SizedBox(height: 100),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppColors.buttonGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            context.pushReplacement(LoginScreen());
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutralWhite,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Menu Item
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryDarkBlue),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryDarkBlue,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.neutralGray,
      ),
      onTap: onTap,
    );
  }
}
