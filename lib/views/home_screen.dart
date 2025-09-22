import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sitikap/api/absen_api.dart';
import 'package:sitikap/api/users_api.dart';
import 'package:sitikap/models/absen/history_absen_model.dart';
import 'package:sitikap/models/absen/list_absen_stats.dart';
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
  RiwayatAbsen? historyAbsen;
  bool isLoadingHistory = false;
  ListAbsenStats? stats; // Gunakan model dari list_absen_stats.dart

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

  // Fungsi untuk mengambil statistik absen
  Future<void> getStats() async {
    try {
      final statsData = await AbsenService.getStatistikAbsen();
      setState(() {
        stats = statsData; // Perbaikan: stats = statsData, bukan stats = stats
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

  // Fungsi untuk membuat data pie chart berdasarkan response API
  List<PieChartSectionData> _getPieChartSections() {
    if (stats == null || stats!.data == null) {
      return [];
    }

    final sections = <PieChartSectionData>[];

    // Data untuk pie chart - sesuaikan dengan response API yang sebenarnya
    // Catatan: Response API memiliki struktur yang berbeda dengan yang diharapkan pie chart
    // Anda perlu menyesuaikan dengan struktur data yang sebenarnya dari API

    // Contoh data dummy untuk demonstrasi
    // Ganti dengan data aktual dari response API
    final values = [
      stats!.data!.totalMasuk?.toDouble() ?? 0.0,
      stats!.data!.totalIzin?.toDouble() ?? 0.0,
      0.0, // Sakit - tidak ada di response, mungkin perlu ditambahkan
      0.0, // Alpha - tidak ada di response, mungkin perlu ditambahkan
      0.0, // Terlambat - tidak ada di response, mungkin perlu ditambahkan
    ];

    final colors = [
      Colors.green, // Hadir/Masuk
      Colors.orange, // Izin
      // Colors.blue, // Sakit
      // Colors.red, // Alpha
      // Colors.amber, // Terlambat
    ];

    final labels = ['Masuk', 'Izin'];

    double total = values.fold(0, (sum, value) => sum + value);

    // Jika tidak ada data, tampilkan section kosong
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

  // Widget untuk menampilkan legenda
  Widget _buildLegendItem(Color color, String text, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Text(
            '$value',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                      const SizedBox(height: 4),
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

              // PIE CHART STATISTIK ABSEN
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.neutralWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Statistik Absensi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDarkBlue,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (stats == null)
                      const Center(child: CircularProgressIndicator())
                    else
                      Row(
                        children: [
                          // Pie Chart
                          Expanded(
                            flex: 5,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: PieChart(
                                PieChartData(
                                  sections: _getPieChartSections(),
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 2,
                                ),
                              ),
                            ),
                          ),

                          // Legenda - sesuaikan dengan data aktual dari API
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLegendItem(
                                  AppColors.accentGreen,
                                  'Masuk',
                                  stats!.data!.totalMasuk ?? 0,
                                ),
                                _buildLegendItem(
                                  Colors.orange,
                                  'Izin',
                                  stats!.data!.totalIzin ?? 0,
                                ),
                                // _buildLegendItem(
                                //   Colors.blue,
                                //   'Sakit',
                                //   0, // Tidak ada data sakit di response
                                // ),
                                // _buildLegendItem(
                                //   Colors.red,
                                //   'Alpha',
                                //   0, // Tidak ada data alpha di response
                                // ),
                                // _buildLegendItem(
                                //   Colors.amber,
                                //   'Terlambat',
                                //   0, // Tidak ada data terlambat di response
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
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

              if (isLoadingHistory)
                const Center(child: CircularProgressIndicator())
              else if (historyAbsen == null || historyAbsen!.data.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.neutralWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
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
