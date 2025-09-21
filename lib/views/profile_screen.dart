import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sitikap/api/users_api.dart';
import 'package:sitikap/extensions/extensions.dart';
import 'package:sitikap/local/shared_preferenced.dart';
import 'package:sitikap/models/users/get_profile.dart';
import 'package:sitikap/utils/colors.dart';
import 'package:sitikap/views/onboarding_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  bool _isSaving = false;
  Getuser? _userProfile;
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final token = await PreferenceHandler.getToken();
      final isLoggedIn = await PreferenceHandler.getLogin();

      if (isLoggedIn == true && token != null) {
        await _fetchUserProfile();
      }

      setState(() {
        _userToken = token;
        _isLoggedIn = isLoggedIn ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      context.showSnackBar("Gagal memuat data pengguna: $e");
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final profile = await AuthenticationAPI.getProfile();
      setState(() {
        _userProfile = profile;
        _nameController.text = profile.data.name;
      });
    } catch (e) {
      print("Error fetching profile: $e");
      context.showSnackBar("Gagal memuat profil: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      context.showSnackBar("Gagal memilih gambar: $e");
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      context.showSnackBar("Nama tidak boleh kosong");
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_selectedImage != null) {
        // Jika ada gambar yang dipilih, update profile dengan foto
        await AuthenticationAPI.editProfileWithPhoto(
          name: _nameController.text,
          jenisKelamin: _userProfile?.data.jenisKelamin ?? "Laki-laki",
          profilePhoto: _selectedImage!,
        );
      } else {
        // Jika tidak ada gambar baru, update hanya nama
        await AuthenticationAPI.editProfile(
          name: _nameController.text,
          jenisKelamin: _userProfile?.data.jenisKelamin ?? "Laki-laki",
        );
      }

      // Refresh profile data untuk mendapatkan data terbaru
      await _fetchUserProfile();

      Navigator.pop(context); // Tutup dialog
      context.showSnackBar("Profile berhasil diupdate");
    } catch (e) {
      print("Error updating profile: $e");
      context.showSnackBar("Gagal mengupdate profil: $e");
    } finally {
      setState(() {
        _isSaving = false;
        _selectedImage = null;
      });
    }
  }

  Future<void> _updateProfilePhotoOnly() async {
    if (_selectedImage == null) {
      context.showSnackBar("Pilih gambar terlebih dahulu");
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await AuthenticationAPI.editProfilePhoto(profilePhoto: _selectedImage!);

      // Tunggu sebentar untuk memastikan server processed
      await Future.delayed(const Duration(seconds: 1));

      // Refresh profile data untuk mendapatkan foto terbaru
      await _fetchUserProfile();

      context.showSnackBar("Foto profil berhasil diupdate");
    } catch (e) {
      print("Error updating profile photo: $e");
      context.showSnackBar("Gagal mengupdate foto profil: $e");
    } finally {
      setState(() {
        _isSaving = false;
        _selectedImage = null;
      });
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Dialog
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Edit Profile",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDarkBlue,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Foto Profil
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              key: ValueKey(
                                _userProfile?.data.profilePhotoUrl ??
                                    'avatar_dialog',
                              ),
                              radius: 40,
                              backgroundColor: AppColors.primaryDarkBlue,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (_userProfile?.data.profilePhotoUrl !=
                                                null &&
                                            _userProfile!
                                                .data
                                                .profilePhotoUrl
                                                .isNotEmpty
                                        ? NetworkImage(
                                            _userProfile!.data.profilePhotoUrl,
                                          )
                                        : null),
                              child:
                                  _selectedImage == null &&
                                      (_userProfile?.data.profilePhotoUrl ==
                                              null ||
                                          _userProfile!
                                              .data
                                              .profilePhotoUrl
                                              .isEmpty)
                                  ? const Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_selectedImage != null) ...[
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: _isSaving
                                ? null
                                : _updateProfilePhotoOnly,
                            child: Text(
                              "Simpan Foto Saja",
                              style: GoogleFonts.poppins(
                                color: AppColors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Form Edit
                      Text(
                        "Nama",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryDarkBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "Masukkan nama lengkap",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.neutralLightGray,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.blue),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.primaryDarkBlue,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tombol Simpan
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isSaving ? null : _saveProfile,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Simpan Perubahan",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Logout",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDarkBlue,
            ),
          ),
          content: Text(
            "Anda yakin ingin logout?",
            style: GoogleFonts.poppins(color: AppColors.neutralDarkGray),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: GoogleFonts.poppins(color: AppColors.neutralGray),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performLogout();
              },
              child: Text(
                "Logout",
                style: GoogleFonts.poppins(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w600,
                ),
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
      await PreferenceHandler.removeLogin();
      await PreferenceHandler.removeToken();

      Navigator.pushNamedAndRemoveUntil(
        context,
        OnboardingScreen.id,
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      context.showSnackBar("Logout gagal: $e");
    }
  }

  void _showComingSoon(String featureName) {
    context.showSnackBar("$featureName akan segera hadir!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Data Diri",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDarkBlue,
              ),
            ),
            _isLoading
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Expanded(
                    child: SingleChildScrollView(
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
                                // Profile Photo dengan tombol edit
                                GestureDetector(
                                  onTap: _showEditProfileDialog,
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        key: ValueKey(
                                          _userProfile?.data.profilePhotoUrl ??
                                              'avatar_main',
                                        ),
                                        radius: 50,
                                        backgroundColor:
                                            AppColors.primaryDarkBlue,
                                        backgroundImage:
                                            _userProfile
                                                        ?.data
                                                        .profilePhotoUrl !=
                                                    null &&
                                                _userProfile!
                                                    .data
                                                    .profilePhotoUrl
                                                    .isNotEmpty
                                            ? NetworkImage(
                                                _userProfile!
                                                    .data
                                                    .profilePhotoUrl,
                                              )
                                            : null,
                                        child:
                                            _userProfile
                                                        ?.data
                                                        .profilePhotoUrl ==
                                                    null ||
                                                _userProfile!
                                                    .data
                                                    .profilePhotoUrl
                                                    .isEmpty
                                            ? const Icon(
                                                Icons.person,
                                                size: 40,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: AppColors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Nama pengguna
                                Text(
                                  _userProfile?.data.name ?? "Guest",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDarkBlue,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Email
                                Text(
                                  _userProfile?.data.email ??
                                      "Email tidak tersedia",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Pelatihan yang diikuti
                                if (_userProfile != null &&
                                    _userProfile!.data.trainingTitle.isNotEmpty)
                                  Column(
                                    children: [
                                      Text(
                                        _userProfile!.data.trainingTitle,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primaryDarkBlue,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (_userProfile!.data.batchKe.isNotEmpty)
                                        Text(
                                          "Batch ${_userProfile!.data.batchKe}",
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
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
                                  onTap: _showEditProfileDialog,
                                ),

                                const Divider(height: 1),

                                // Pengaturan
                                _buildMenuOption(
                                  icon: Icons.settings,
                                  title: "Pengaturan",
                                  onTap: () => _showComingSoon("Pengaturan"),
                                ),

                                const Divider(height: 1),

                                // Tentang Aplikasi
                                _buildMenuOption(
                                  icon: Icons.info_outline,
                                  title: "Tentang Aplikasi",
                                  onTap: () =>
                                      _showComingSoon("Tentang Aplikasi"),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Logout Button (hanya tampil jika login)
                          if (_isLoggedIn)
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
                                  onPressed: _logout,
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

extension on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
