import 'package:flutter/material.dart';
import 'package:sitikap/api/users_api.dart';
import 'package:sitikap/models/users/get_user.dart';
import 'package:sitikap/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const id = "/home_screen";
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // late Future<Getuser>? futureUser;
  Getuser? user;

  // dummy data absensi
  String hadirJam = "08:05 WIB";
  List<Map<String, String>> riwayat = [
    {"tanggal": "15 Sept 2025", "status": "Hadir"},
    {"tanggal": "14 Sept 2025", "status": "Hadir"},
    {"tanggal": "13 Sept 2025", "status": "Terlambat"},
    {"tanggal": "12 Sept 2025", "status": "Alpha"},
    {"tanggal": "11 Sept 2025", "status": "Hadir"},
  ];

  @override
  void initState() {
    super.initState();
    getuserdata();
    // futureUser = AuthenticationAPI.getProfile();
  }

  Future<void> getuserdata() async {
    try {
      final data = await AuthenticationAPI.getProfile();
      setState(() {
        user = data;
      });
    } catch (e) {
      print("user get error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralLightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Selamat Datang,",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${user?.data.name ?? "loading"}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDarkBlue,
                        ),
                      ),

                      // FutureBuilder<Getuser>(
                      //   // future: futureUser,
                      //   builder: (context, snapshot) {
                      //     if (snapshot.connectionState ==
                      //         ConnectionState.waiting) {
                      //       return
                      // Text(
                      //         "Loading...",
                      //         style: TextStyle(
                      //           fontSize: 22,
                      //           fontWeight: FontWeight.bold,
                      //           color: AppColors.primaryDarkBlue,
                      //         ),
                      //       );
                      //     } else if (snapshot.hasError) {
                      //       return Text(
                      //         "User Absensi",
                      //         style: TextStyle(
                      //           fontSize: 20,
                      //           fontWeight: FontWeight.bold,
                      //           color: AppColors.primaryDarkBlue,
                      //         ),
                      //       );
                      //     } else if (snapshot.hasData) {
                      //       final user = snapshot.data!.data;
                      //       return Text(
                      //         "${user.name}",
                      //         style: TextStyle(
                      //           fontSize: 20,
                      //           fontWeight: FontWeight.bold,
                      //           color: AppColors.primaryDarkBlue,
                      //         ),
                      //       );
                      //     } else {
                      //       return Text(
                      //         "User Absensi",
                      //         style: TextStyle(
                      //           fontSize: 20,
                      //           fontWeight: FontWeight.bold,
                      //           color: AppColors.primaryDarkBlue,
                      //         ),
                      //       );
                      //     }
                      //   },
                      // ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 26,
                    backgroundImage:
                        (user?.data.profilePhotoUrl != null &&
                            user!.data.profilePhotoUrl.isNotEmpty)
                        ? NetworkImage(user!.data.profilePhotoUrl)
                        : null,
                    backgroundColor: Colors.white,
                    child:
                        (user?.data.profilePhotoUrl == null ||
                            user!.data.profilePhotoUrl.isEmpty)
                        ? const Icon(Icons.person, size: 28, color: Colors.grey)
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // CARD INFO KEHADIRAN
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.neutralWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Jl. Karet Pasar Baru Barat, Kec Tanah Abang, Kota Jakarta Pusat ",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Hadir: $hadirJam",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // TOMBOL ABSEN
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    // contoh aksi absen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Absen berhasil!"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        "Absen Sekarang",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // RIWAYAT ABSENSI
              const Text(
                "Riwayat Absensi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkBlue,
                ),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: riwayat.length,
                itemBuilder: (context, index) {
                  final item = riwayat[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.neutralWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item["tanggal"]!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          item["status"]!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item["status"] == "Hadir"
                                ? AppColors.blue
                                : item["status"] == "Terlambat"
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
