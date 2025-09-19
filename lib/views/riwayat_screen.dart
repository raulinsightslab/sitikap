import 'package:flutter/material.dart';
import 'package:sitikap/api/absen_api.dart';
import 'package:sitikap/models/absen/history_absen_model.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  HistoryAbsen? historyAbsen;
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final history = await AbsenService.getHistory();
      if (mounted) {
        setState(() {
          historyAbsen = history;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  String _getDayName(DateTime date) {
    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    return days[date.weekday];
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Colors.green;
      case 'terlambat':
        return Colors.orange;
      case 'izin':
        return Colors.blue;
      case 'sakit':
        return Colors.purple;
      case 'alpha':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildHistoryItem(Datum absen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getDayName(absen.attendanceDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(absen.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(absen.status),
                    width: 1,
                  ),
                ),
                child: Text(
                  absen.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(absen.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(absen.attendanceDate),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeCard(
                  icon: Icons.login,
                  title: 'Masuk',
                  time: absen.checkInTime.isNotEmpty ? absen.checkInTime : '-',
                  // address: absen.checkInAddress,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeCard(
                  icon: Icons.logout,
                  title: 'Pulang',
                  time: absen.checkOutTime ?? '-',
                  // address: absen.checkOutAddress ?? 'Belum check out',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          if (absen.alasanIzin != null &&
              absen.alasanIzin.toString().isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Alasan Izin: ${absen.alasanIzin}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required IconData icon,
    required String title,
    required String time,
    // required String address,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          // Text(
          //   address,
          //   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          //   maxLines: 2,
          //   overflow: TextOverflow.ellipsis,
          // ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Belum ada riwayat absen',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadHistoryData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            'Terjadi kesalahan',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHistoryData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistoryData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? _buildErrorState()
          : historyAbsen == null || historyAbsen!.data.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadHistoryData,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: historyAbsen!.data.length,
                itemBuilder: (context, index) {
                  final absen = historyAbsen!.data[index];
                  return _buildHistoryItem(absen);
                },
              ),
            ),
    );
  }
}
