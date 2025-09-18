import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sitikap/api/users.dart';
import 'package:sitikap/extensions/extensions.dart';
import 'package:sitikap/models/list_batch.dart' as batch_model;
import 'package:sitikap/models/list_pelatihan.dart' as training_model;
import 'package:sitikap/utils/colors.dart';
import 'package:sitikap/views/login_screen.dart';
import 'package:sitikap/views/onboarding_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const id = "/register_screen";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Variabel untuk foto
  File? _profilePhoto;
  final ImagePicker _picker = ImagePicker();

  // Controller untuk text field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variabel untuk dropdown
  String? _selectedGender;
  batch_model.Datum? _selectedBatch;
  training_model.Datum? _selectedTraining;

  // Data dari API
  List<batch_model.Datum> _batches = [];
  List<training_model.Datum> _trainings = [];

  // State loading dan error
  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _errorMessage;

  // Page Controller untuk slide form
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadBatchAndTrainingData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Method untuk mengambil data batch dan training
  Future<void> _loadBatchAndTrainingData() async {
    try {
      setState(() {
        _isLoadingData = true;
        _errorMessage = null;
      });

      final results = await Future.wait([
        AuthenticationAPI.getlistbatch(),
        AuthenticationAPI.getlistpelatihan(),
      ]);

      final batchData = results[0] as batch_model.Listbatch;
      final trainingData = results[1] as training_model.Listpelatihan;

      setState(() {
        _batches = batchData.data;
        _trainings = trainingData.data;
        _isLoadingData = false;

        if (_batches.isNotEmpty) _selectedBatch = null;
        if (_trainings.isNotEmpty) _selectedTraining = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat data: ${e.toString()}";
        _isLoadingData = false;
      });
    }
  }

  // Method untuk memilih foto dari gallery
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (image != null) {
        setState(() {
          _profilePhoto = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memilih gambar: $e")));
    }
  }

  // Method untuk register
  Future<void> _register() async {
    if (_profilePhoto == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Harap pilih foto profil")));
      return;
    }

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _selectedGender == null ||
        _selectedBatch == null ||
        _selectedTraining == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Harap isi semua field")));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthenticationAPI.registerUser(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        jenisKelamin: _selectedGender!,
        profilePhoto: _profilePhoto!,
        batchId: _selectedBatch!.id,
        trainingId: _selectedTraining!.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? "Registrasi berhasil")),
      );

      // Navigasi ke halaman login
      context.pushReplacement(const LoginScreen());
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registrasi gagal: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method untuk pindah ke halaman sebelumnya
  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pushReplacement(const OnboardingScreen());
    }
  }

  // Method untuk pindah ke halaman berikutnya
  void _goToNextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Widget untuk indicator progress
  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? AppColors.primaryDarkBlue
                : Colors.grey[300],
          ),
        );
      }),
    );
  }

  // Widget untuk form data diri (halaman 1)
  Widget _buildPersonalDataForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            "Data Diri",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 20),

          // Upload Foto
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: _profilePhoto != null
                  ? FileImage(_profilePhoto!)
                  : null,
              child: _profilePhoto == null
                  ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Tap untuk upload foto",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Nama
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Nama Lengkap",
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 16),

          // Email
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 16),

          // Jenis Kelamin
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: InputDecoration(
              labelText: "Jenis Kelamin",
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            items: const [
              DropdownMenuItem(value: "L", child: Text("Laki-laki")),
              DropdownMenuItem(value: "P", child: Text("Perempuan")),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk form batch dan training (halaman 2)
  Widget _buildBatchTrainingForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            "Program Training",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 20),

          // Batch Dropdown
          _isLoadingData
              ? const CircularProgressIndicator()
              : _batches.isEmpty
              ? const Text(
                  "Tidak ada data batch tersedia",
                  style: TextStyle(color: Colors.red),
                )
              : DropdownButtonFormField<batch_model.Datum>(
                  value: _selectedBatch,
                  decoration: InputDecoration(
                    labelText: "Batch",
                    prefixIcon: const Icon(Icons.group),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  items: _batches.map((batch) {
                    return DropdownMenuItem<batch_model.Datum>(
                      value: batch,
                      child: Text(
                        "Batch ${batch.batchKe}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBatch = value;
                    });
                  },
                ),
          const SizedBox(height: 16),

          // Training Dropdown dengan custom dialog
          _isLoadingData
              ? const CircularProgressIndicator()
              : _trainings.isEmpty
              ? const Text(
                  "Tidak ada data training tersedia",
                  style: TextStyle(color: Colors.red),
                )
              : TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Training",
                    prefixIcon: const Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  controller: TextEditingController(
                    text: _selectedTraining?.title ?? "",
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Pilih Training",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 300,
                                  width: double.infinity,
                                  child: ListView.builder(
                                    itemCount: _trainings.length,
                                    itemBuilder: (context, index) {
                                      final training = _trainings[index];
                                      return Card(
                                        child: ListTile(
                                          title: Text(
                                            training.title,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedTraining = training;
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }

  // Widget untuk form password (halaman 3) - DIUBAH: Hapus tombol daftar dari sini
  Widget _buildPasswordForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            "Buat Password",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 20),

          // Password
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 16),

          // Konfirmasi Password
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Konfirmasi Password",
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _goToPreviousPage,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Judul
              Text(
                "Daftar Akun Baru",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Lengkapi data diri untuk membuat akun",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),

              // Progress Indicator
              _buildProgressIndicator(),
              const SizedBox(height: 20),

              // Form Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildPersonalDataForm(),
                    _buildBatchTrainingForm(),
                    _buildPasswordForm(),
                  ],
                ),
              ),

              // Navigation Buttons - DIUBAH: Tombol daftar dipindah ke sini
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _currentPage < 2
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDarkBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _goToNextPage,
                        child: Text(
                          "Lanjut",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DecoratedBox(
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
                          onPressed: _register,
                          child: Text(
                            "Daftar",
                            style: GoogleFonts.poppins(
                              color: AppColors.neutralWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
