import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sitikap/api/absen_api.dart';
import 'package:sitikap/api/users_api.dart';
import 'package:sitikap/extensions/extensions.dart';
import 'package:sitikap/models/absen/history_absen_model.dart';
import 'package:sitikap/models/absen/list_absen_stats.dart';
import 'package:sitikap/models/absen/today_model.dart';
import 'package:sitikap/models/users/get_profile.dart';
import 'package:sitikap/utils/colors.dart';
import 'package:sitikap/widget/botnav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const id = "/home_screen";
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Getuser? user;
  RiwayatAbsen? historyAbsen;
  bool isLoadingHistory = false;
  ListAbsenStats? stats;
  AbsenTodayModels? todayAttendance;
  bool isLoadingToday = false;

  @override
  void initState() {
    super.initState();
    getuserdata();
    getHistoryAbsen();
    getStats();
    getTodayAttendance();
  }

  Future<void> getuserdata() async {
    try {
      final data = await AuthenticationAPI.getProfile();
      if (mounted) {
        setState(() {
          user = data;
        });
      }
    } catch (e) {
      print("user get error: $e");
    }
  }

  Future<void> getHistoryAbsen() async {
    try {
      if (mounted) {
        setState(() => isLoadingHistory = true);
      }
      final history = await AbsenService.getHistory();
      if (mounted) {
        setState(() {
          historyAbsen = history;
        });
      }
    } catch (e) {
      print("Error getting history: $e");
    } finally {
      if (mounted) {
        setState(() => isLoadingHistory = false);
      }
    }
  }

  Future<void> getStats() async {
    try {
      final statsData = await AbsenService.getStatistikAbsen();
      if (mounted) {
        setState(() {
          stats = statsData;
        });
      }
    } catch (e) {
      print("Error getting stats: $e");
    }
  }

  Future<void> getTodayAttendance() async {
    try {
      if (mounted) {
        setState(() => isLoadingToday = true);
      }
      final attendance = await AbsenService.getToday();
      if (mounted) {
        setState(() {
          todayAttendance = attendance;
        });
      }
    } catch (e) {
      print("Error getting today attendance: $e");
    } finally {
      if (mounted) {
        setState(() => isLoadingToday = false);
      }
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
    return "Tidak Hadir";
  }

  Color _getStatusColor(Datum absen) {
    if (absen.checkOutTime != null) {
      return AppColors.blue;
    } else if (absen.checkInTime.isNotEmpty) {
      return Colors.green;
    }
    return Colors.red;
  }

  List<PieChartSectionData> _getPieChartSections() {
    if (stats == null || stats!.data == null) {
      return [];
    }

    final sections = <PieChartSectionData>[];

    final values = [
      stats!.data!.totalMasuk?.toDouble() ?? 0.0,
      stats!.data!.totalIzin?.toDouble() ?? 0.0,
    ];

    final colors = [AppColors.blue, AppColors.accentGreen];

    double total = values.fold(0, (sum, value) => sum + value);

    if (total == 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: '0',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      return sections;
    }

    for (int i = 0; i < values.length; i++) {
      if (values[i] > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[i],
            value: values[i],
            title: '${values[i].toInt()}',
            radius: 40,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    }

    return sections;
  }

  Widget _buildLegendItem(Color color, String text, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Hitung progress training berdasarkan riwayat absensi
  Map<String, dynamic> _calculateTrainingProgress() {
    if (historyAbsen == null || historyAbsen!.data.isEmpty) {
      return {
        'progress': 0.0,
        'daysCompleted': 0,
        'totalDays': 45,
        'status': 'Belum Mulai',
        'statusColor': Colors.grey,
      };
    }

    // Hitung jumlah hari unik yang sudah absen
    final uniqueAbsenDates = historyAbsen!.data
        .map(
          (absen) => DateTime(
            absen.attendanceDate.year,
            absen.attendanceDate.month,
            absen.attendanceDate.day,
          ),
        )
        .toSet()
        .length;

    final daysCompleted = uniqueAbsenDates;
    final totalDays = 45;
    final progress = daysCompleted / totalDays;

    String status;
    Color statusColor;

    if (daysCompleted == 0) {
      status = 'Belum Mulai';
      statusColor = Colors.grey;
    } else if (daysCompleted < totalDays) {
      status = 'Dalam Progress';
      statusColor = Colors.amber;
    } else {
      status = 'Selesai';
      statusColor = AppColors.accentGreen;
    }

    return {
      'progress': progress.clamp(0.0, 1.0),
      'daysCompleted': daysCompleted,
      'totalDays': totalDays,
      'status': status,
      'statusColor': statusColor,
    };
  }

  // Widget untuk chip informasi
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryDarkBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primaryDarkBlue),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.primaryDarkBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Pesan motivasi berdasarkan progress
  String _getMotivationalMessage(int daysCompleted, int totalDays) {
    final percentage = (daysCompleted / totalDays * 100).toInt();

    if (percentage < 25) {
      return "Langkah awal yang baik! Terus konsisten! 💪";
    } else if (percentage < 50) {
      return "Sudah $percentage%! Pertahankan semangatnya! 🔥";
    } else if (percentage < 75) {
      return "Luar biasa! Sudah lebih dari setengah jalan! 🚀";
    } else if (percentage < 100) {
      return "Hampir sampai! Tinggal ${totalDays - daysCompleted} hari lagi! 🎯";
    } else {
      return "Selesai! Selamat telah menyelesaikan training! 🎉";
    }
  }

  // Widget untuk status absen hari ini - DIUBAH
  Widget _buildTodayAttendance() {
    if (isLoadingToday) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryDarkBlue,
            ),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final todayDate = "${now.day} ${_getMonthName(now.month)} ${now.year}";

    // Handle status dengan logika yang lebih robust
    final isIzin = todayAttendance?.data?.status == "izin";

    // Logika yang lebih akurat untuk menentukan status check in/out
    final hasCheckedIn =
        todayAttendance?.data?.checkInTime != null &&
        todayAttendance!.data!.checkInTime!.isNotEmpty &&
        todayAttendance!.data!.checkInTime != "--:--" &&
        todayAttendance!.data!.checkInTime != "null";

    final hasCheckedOut =
        todayAttendance?.data?.checkOutTime != null &&
        todayAttendance!.data!.checkOutTime!.isNotEmpty &&
        todayAttendance!.data!.checkOutTime != "--:--" &&
        todayAttendance!.data!.checkOutTime != "null";

    final checkInTime = isIzin
        ? "--:--"
        : (hasCheckedIn ? todayAttendance!.data!.checkInTime! : "--:--");

    final checkOutTime = isIzin
        ? "--:--"
        : (hasCheckedOut ? todayAttendance!.data!.checkOutTime! : "--:--");

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryDarkBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isIzin ? Icons.assignment_outlined : Icons.today_outlined,
                  size: 18,
                  color: AppColors.primaryDarkBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isIzin ? "Status Izin Hari Ini" : "Status Absen Hari Ini",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Alamat (jika bukan izin)
          if (!isIzin) ...[
            Text(
              "Jl. Karet Pasar Baru Barat, Kec. Tanah Abang, Kota Jakarta Pusat",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
          ],

          // Kotak tanggal hari ini
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryDarkBlue, width: 1),
            ),
            child: Text(
              todayDate,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDarkBlue,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Check In & Check Out Status atau Status Izin
          if (isIzin)
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber, width: 1),
                ),
                child: Text(
                  "Hari ini izin",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      "Check In",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      checkInTime,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: hasCheckedIn ? AppColors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                  child: VerticalDivider(
                    color: Colors.grey[300],
                    thickness: 1,
                    width: 32,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "Check Out",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      checkOutTime,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: hasCheckedOut ? AppColors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Jarak dan tombol buka map
          // if (!isIzin)
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Row(
          //         children: [
          //           Icon(Icons.location_on, size: 16, color: Colors.grey),
          //           const SizedBox(width: 4),
          //           Text(
          //             "Jarak dari lokasi",
          //             style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          //           ),
          //           const SizedBox(width: 4),
          //           Text(
          //             "4.98m",
          //             style: TextStyle(
          //               fontSize: 12,
          //               fontWeight: FontWeight.bold,
          //               color: AppColors.primaryDarkBlue,
          //             ),
          //           ),
          //         ],
          //       ),
          //       ElevatedButton(
          //         onPressed: () {
          //           // Navigate to absen map screen
          //           context.pushReplacement(Botnav(initialPage: 2));
          //         },
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: AppColors.primaryDarkBlue,
          //           foregroundColor: Colors.white,
          //           padding: const EdgeInsets.symmetric(
          //             horizontal: 16,
          //             vertical: 8,
          //           ),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(8),
          //           ),
          //         ),
          //         child: const Text("Buka Map", style: TextStyle(fontSize: 12)),
          //       ),
          //     ],
          //   ),
        ],
      ),
    );
  }

  // Widget untuk training progress
  Widget _buildTrainingProgress() {
    if (user?.data.training == null) return const SizedBox.shrink();

    final progressData = _calculateTrainingProgress();
    final daysCompleted = progressData['daysCompleted'] as int;
    final progress = progressData['progress'] as double;
    final totalDays = progressData['totalDays'] as int;
    final status = progressData['status'] as String;
    final statusColor = progressData['statusColor'] as Color;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryDarkBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.school_outlined,
                  size: 18,
                  color: AppColors.primaryDarkBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Progress Training",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Training Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user!.data.training.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildInfoChip(
                    Icons.group,
                    "Batch ${user?.data.batchKe ?? '-'}",
                  ),
                  _buildInfoChip(Icons.flag, "Target: $totalDays Hari"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Progress Kehadiran",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87.withOpacity(0.7),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Progress Bar
              Stack(
                children: [
                  // Background progress bar
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.neutralLightGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  // Progress fill
                  Container(
                    height: 8,
                    width: MediaQuery.of(context).size.width * progress,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradienbiru,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  // Indicator titik di tengah
                  if (progress > 0 && progress < 1)
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.5 - 4,
                      top: -2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryDarkBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryDarkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$daysCompleted/$totalDays hari",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black87.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              if (daysCompleted > 0 && daysCompleted < totalDays)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getMotivationalMessage(daysCompleted, totalDays),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black87.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralLightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER GRADIENT BACKGROUND
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(gradient: AppColors.gradienbiru),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Selamat Datang,",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.data.name ?? "Loading...",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (user?.data.training != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      "${_calculateTrainingProgress()['daysCompleted']} hari sudah absen",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          CircleAvatar(
                            radius: 38,
                            backgroundImage:
                                (user?.data.profilePhotoUrl != null &&
                                    user!.data.profilePhotoUrl.isNotEmpty)
                                ? NetworkImage(user!.data.profilePhotoUrl)
                                : null,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            child:
                                (user?.data.profilePhotoUrl == null ||
                                    user!.data.profilePhotoUrl.isEmpty)
                                ? const Icon(
                                    Icons.person,
                                    size: 24,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // STATUS ABSEN HARI INI - POSITIONED RELATIVE
              Transform.translate(
                offset: const Offset(0, -30), // Mengangkat card ke atas
                child: _buildTodayAttendance(),
              ),
              // TRAINING PROGRESS SECTION (jika ada training)
              if (user?.data.training != null)
                Transform.translate(
                  offset: const Offset(0, -20), // Mengangkat card ke atas
                  child: _buildTrainingProgress(),
                ),
              // MAIN CONTENT AREA
              Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.neutralLightGray,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // STATISTICS SECTION
                        Container(
                          width: double.infinity,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header dengan icon
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryDarkBlue
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.bar_chart_outlined,
                                      size: 18,
                                      color: AppColors.primaryDarkBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Statistik Absensi",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryDarkBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (stats == null)
                                const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryDarkBlue,
                                    ),
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: PieChart(
                                          PieChartData(
                                            sections: _getPieChartSections(),
                                            centerSpaceRadius: 30,
                                            sectionsSpace: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        children: [
                                          _buildLegendItem(
                                            AppColors.blue,
                                            'Masuk',
                                            stats!.data!.totalMasuk ?? 0,
                                          ),
                                          _buildLegendItem(
                                            AppColors.accentGreen,
                                            'Izin',
                                            stats!.data!.totalIzin ?? 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // HISTORY SECTION
                        Container(
                          width: double.infinity,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header dengan icon
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryDarkBlue
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.history_outlined,
                                      size: 18,
                                      color: AppColors.primaryDarkBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Riwayat Absensi",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryDarkBlue,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.pushReplacement(
                                        Botnav(initialPage: 1),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Row(
                                      children: [
                                        Text(
                                          "Lihat Semua",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.primaryDarkBlue,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 12,
                                          color: AppColors.primaryDarkBlue,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (isLoadingHistory)
                                const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryDarkBlue,
                                    ),
                                  ),
                                )
                              else if (historyAbsen == null ||
                                  historyAbsen!.data.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.history,
                                          size: 40,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Belum ada riwayat absen",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  children: [
                                    ...historyAbsen!.data.take(3).map((absen) {
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.neutralLightGray,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                  absen,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Icon(
                                                absen.checkOutTime != null
                                                    ? Icons.logout
                                                    : Icons.login,
                                                color: _getStatusColor(absen),
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _formatDate(
                                                      absen.attendanceDate,
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    _getStatusText(absen),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right,
                                              size: 16,
                                              color: Colors.grey[400],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    if (historyAbsen!.data.length > 3)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Center(
                                          child: Text(
                                            "+ ${historyAbsen!.data.length - 3} riwayat lainnya",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.primaryDarkBlue,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
