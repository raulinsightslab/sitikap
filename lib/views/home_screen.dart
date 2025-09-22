import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sitikap/api/absen_api.dart';
import 'package:sitikap/api/users_api.dart';
import 'package:sitikap/extensions/extensions.dart';
import 'package:sitikap/models/absen/history_absen_model.dart';
import 'package:sitikap/models/absen/list_absen_stats.dart';
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

  @override
  void initState() {
    super.initState();
    getuserdata();
    getHistoryAbsen();
    getStats();
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

  Future<void> getStats() async {
    try {
      final statsData = await AbsenService.getStatistikAbsen();
      setState(() {
        stats = statsData;
      });
    } catch (e) {
      print("Error getting stats: $e");
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

    final colors = [AppColors.accentGreen, Colors.orangeAccent];

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
      statusColor = Colors.green;
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
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final progressData = _calculateTrainingProgress();
    final daysCompleted = progressData['daysCompleted'] as int;
    final progress = progressData['progress'] as double;
    final totalDays = progressData['totalDays'] as int;
    final status = progressData['status'] as String;
    final statusColor = progressData['statusColor'] as Color;

    return Scaffold(
      backgroundColor: AppColors.neutralLightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER SECTION
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selamat Datang, $user",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.data.name ?? "Loading...",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDarkBlue,
                            ),
                          ),
                          if (daysCompleted > 0) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.accentGreen,
                                ),
                              ),
                              child: Text(
                                "$daysCompleted hari sudah absen",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.accentGreen,
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
                      radius: 28,
                      backgroundImage:
                          (user?.data.profilePhotoUrl != null &&
                              user!.data.profilePhotoUrl.isNotEmpty)
                          ? NetworkImage(user!.data.profilePhotoUrl)
                          : null,
                      backgroundColor: AppColors.lightBlue,
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
              ),

              const SizedBox(height: 16),

              // TRAINING PROGRESS SECTION
              if (user?.data.training != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
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
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.school_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Progress Training",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                              _buildInfoChip(
                                Icons.flag,
                                "Target: $totalDays Hari",
                              ),
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
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
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
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress == 1.0 ? Colors.green : Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            minHeight: 6,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${(progress * 100).toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$daysCompleted/$totalDays hari",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          if (daysCompleted > 0 && daysCompleted < totalDays)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getMotivationalMessage(
                                  daysCompleted,
                                  totalDays,
                                ),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.8),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

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
                    const Text(
                      "Statistik Absensi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDarkBlue,
                      ),
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
                                  AppColors.accentGreen,
                                  'Masuk',
                                  stats!.data!.totalMasuk ?? 0,
                                ),
                                _buildLegendItem(
                                  Colors.orangeAccent,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Riwayat Absensi",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkBlue,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.pushReplacement(Botnav(initialPage: 1));
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                    else if (historyAbsen == null || historyAbsen!.data.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
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
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.neutralLightGray,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        absen,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
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
                                          _formatDate(absen.attendanceDate),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
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
    );
  }
}
