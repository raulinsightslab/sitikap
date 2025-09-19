import 'package:flutter/material.dart';
import 'package:sitikap/api/absen_api.dart';
import 'package:sitikap/api/users_api.dart';
import 'package:sitikap/models/absen/history_absen_model.dart';
import 'package:sitikap/models/users/get_profile.dart';
import 'package:sitikap/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const id = "/home_screen";
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Getuser? user;
  HistoryAbsen? historyAbsen;
  bool isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    getuserdata();
    getHistoryAbsen();
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

  Future<void> getHistoryAbsen() async {
    try {
      setState(() => isLoadingHistory = true);
      // Anda perlu membuat fungsi getHistory() di AbsenService
      // atau menggunakan endpoint yang sesuai untuk mengambil riwayat absen
      final history = await AbsenService.getHistory();
      setState(() {
        historyAbsen = history;
      });
    } catch (e) {
      print("Error getting history: $e");
    } finally {
      setState(() => isLoadingHistory = false);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day} ${_getMonthName(date.month)} ${date.year}";
  }

  String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    return months[month - 1];
  }

  String _getStatusText(Datum absen) {
    if (absen.checkOutTime != null) {
      return "Check Out: ${absen.checkOutTime}";
    } else if (absen.checkInTime.isNotEmpty) {
      return "Check In: ${absen.checkInTime}";
    }
    return "Tidak Absen";
  }

  Color _getStatusColor(Datum absen) {
    if (absen.checkOutTime != null) {
      return AppColors.blue; // Warna untuk check out
    } else if (absen.checkInTime.isNotEmpty) {
      return Colors.green; // Warna untuk check in
    }
    return Colors.red; // Warna untuk tidak absen
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

              // TOMBOL ABSEN
              // Center(
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 50,
              //         vertical: 16,
              //       ),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(30),
              //       ),
              //       backgroundColor: Colors.transparent,
              //       shadowColor: Colors.transparent,
              //     ),
              //     onPressed: () {
              //       Navigator.pushNamed(context, '/absen_map');
              //     },
              //     child: Ink(
              //       decoration: BoxDecoration(
              //         gradient: AppColors.buttonGradient,
              //         borderRadius: BorderRadius.circular(30),
              //       ),
              //       child: Container(
              //         padding: const EdgeInsets.symmetric(
              //           horizontal: 24,
              //           vertical: 12,
              //         ),
              //         alignment: Alignment.center,
              //         child: const Text(
              //           "Absen Sekarang",
              //           style: TextStyle(
              //             fontSize: 16,
              //             fontWeight: FontWeight.bold,
              //             color: Colors.white,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
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

              if (isLoadingHistory)
                Center(child: CircularProgressIndicator())
              else if (historyAbsen == null || historyAbsen!.data.isEmpty)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.neutralWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      "Belum ada riwayat absen",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: historyAbsen!.data.length,
                  itemBuilder: (context, index) {
                    final absen = historyAbsen!.data[index];
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
                              Icon(
                                absen.checkOutTime != null
                                    ? Icons.logout
                                    : Icons.login,
                                color: _getStatusColor(absen),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(absen.attendanceDate),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  // Text(
                                  //   absen.checkInAddress,
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     color: Colors.grey[600],
                                  //   ),
                                  //   maxLines: 1,
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            _getStatusText(absen),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(absen),
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
