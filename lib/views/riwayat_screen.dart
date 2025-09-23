import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sitikap/api/absen_api.dart';
import 'package:sitikap/models/absen/history_absen_model.dart';
import 'package:sitikap/utils/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class RiwayatScreen extends StatefulWidget {
  static const id = "/riwayatabsen";
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  late Future<RiwayatAbsen> _historyFuture;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  List<Datum> _filteredData = [];
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = true;

  // Warna status yang selaras dengan gradient
  final Color _tepatWaktuColor = AppColors.blue;
  final Color _tepatWaktuLightColor = const Color(0xFFE8F5E8);
  final Color _terlambatColor = const Color(0xFFFF9800);
  final Color _terlambatLightColor = const Color(0xFFFFF3E0);
  final Color _tidakHadirColor = const Color(0xFFF44336);
  final Color _tidakHadirLightColor = const Color(0xFFFFEBEE);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _historyFuture = AbsenService.getHistory();
    });
  }

  Future<void> _onRefresh() async {
    _loadData();
    await _historyFuture;
  }

  void _applyDateFilter() {
    _historyFuture.then((riwayatAbsen) {
      if (mounted) {
        setState(() {
          if (_selectedStartDate != null && _selectedEndDate != null) {
            DateTime startDate = _selectedStartDate!;
            DateTime endDate = _selectedEndDate!;

            if (startDate.isAfter(endDate)) {
              DateTime temp = startDate;
              startDate = endDate;
              endDate = temp;
            }

            _filteredData = riwayatAbsen.data.where((absen) {
              final attendanceDate = absen.attendanceDate;
              return (attendanceDate.isAfter(
                    startDate.subtract(const Duration(days: 1)),
                  ) &&
                  attendanceDate.isBefore(
                    endDate.add(const Duration(days: 1)),
                  ));
            }).toList();
          } else {
            _filteredData = riwayatAbsen.data;
          }
        });
      }
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
      _historyFuture.then((riwayatAbsen) {
        if (mounted) {
          setState(() {
            _filteredData = riwayatAbsen.data;
          });
        }
      });
    });
  }

  void _toggleCalendar() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Riwayat Absensi',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.neutralWhite,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.primaryDarkBlue,
              size: 28,
            ),
            onPressed: _toggleCalendar,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primaryDarkBlue,
        child: Column(
          children: [
            // Kalender Filter dengan animasi yang lebih smooth
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded ? _buildCalendarSection() : const SizedBox(),
            ),

            // Status Legend
            _buildStatusLegend(),

            // Daftar Riwayat dengan Expanded dan padding untuk navbar
            Expanded(
              child: FutureBuilder<RiwayatAbsen>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  } else if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  } else if (snapshot.hasData) {
                    final data =
                        _selectedStartDate != null && _selectedEndDate != null
                        ? _filteredData
                        : snapshot.data!.data;

                    if (data.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildAbsenList(data);
                  } else {
                    return _buildEmptyState();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedStartDate, day) ||
                    isSameDay(_selectedEndDate, day);
              },
              rangeStartDay: _selectedStartDate,
              rangeEndDay: _selectedEndDate,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  if (_selectedStartDate == null) {
                    _selectedStartDate = selectedDay;
                  } else if (_selectedEndDate == null) {
                    _selectedEndDate = selectedDay;
                    if (_selectedStartDate!.isAfter(_selectedEndDate!)) {
                      DateTime temp = _selectedStartDate!;
                      _selectedStartDate = _selectedEndDate;
                      _selectedEndDate = temp;
                    }
                  } else {
                    _selectedStartDate = selectedDay;
                    _selectedEndDate = null;
                  }
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  gradient: AppColors.gradienbiru,
                  shape: BoxShape.circle,
                ),
                rangeStartDecoration: BoxDecoration(
                  gradient: AppColors.gradienbiru,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  gradient: AppColors.gradienbiru,
                  shape: BoxShape.circle,
                ),
                rangeHighlightColor: AppColors.primaryDarkBlue.withOpacity(0.1),
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryDarkBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: GoogleFonts.poppins(
                  color: AppColors.primaryDarkBlue,
                  fontWeight: FontWeight.w600,
                ),
                defaultTextStyle: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 14,
                ),
                weekendTextStyle: GoogleFonts.poppins(
                  color: Colors.red,
                  fontSize: 14,
                ),
                outsideTextStyle: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: GoogleFonts.poppins(
                  color: AppColors.primaryDarkBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: AppColors.primaryDarkBlue,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: AppColors.primaryDarkBlue,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.poppins(
                  color: AppColors.primaryDarkBlue,
                  fontWeight: FontWeight.w500,
                ),
                weekendStyle: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_selectedStartDate != null || _selectedEndDate != null)
              _buildFilterInfo(),

            const SizedBox(height: 8),
            _buildFilterButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryDarkBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _selectedStartDate != null && _selectedEndDate != null
            ? 'Filter: ${DateFormat('dd MMM yyyy').format(_selectedStartDate!)} - ${DateFormat('dd MMM yyyy').format(_selectedEndDate!)}'
            : _selectedStartDate != null
            ? 'Filter: ${DateFormat('dd MMM yyyy').format(_selectedStartDate!)}'
            : 'Filter: ${DateFormat('dd MMM yyyy').format(_selectedEndDate!)}',
        style: GoogleFonts.poppins(
          color: AppColors.primaryDarkBlue,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearFilter,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryDarkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: AppColors.primaryDarkBlue, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'Reset Filter',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.gradienbiru,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDarkBlue.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _applyDateFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Terapkan Filter',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusLegendItem(_tepatWaktuColor, 'Tepat Waktu'),
          _buildStatusLegendItem(_terlambatColor, 'Terlambat'),
          _buildStatusLegendItem(_tidakHadirColor, 'Tidak Hadir'),
        ],
      ),
    );
  }

  Widget _buildStatusLegendItem(Color color, String text) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: GoogleFonts.poppins(color: AppColors.neutralDarkGray),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: GoogleFonts.poppins(
              color: AppColors.neutralDarkGray,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.poppins(
              color: AppColors.neutralGray,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 48,
            color: AppColors.neutralGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data absensi',
            style: GoogleFonts.poppins(
              color: AppColors.neutralDarkGray,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsenList(List<Datum> data) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 80, // Padding untuk menghindari tertutup navbar
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final absen = data[index];
        return _buildAbsenCard(absen);
      },
    );
  }

  Widget _buildAbsenCard(Datum absen) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm');

    Map<String, dynamic> statusInfo = _getStatusInfo(absen);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan tanggal dan status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dateFormat.format(absen.attendanceDate),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDarkBlue,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusInfo['lightColor'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusInfo['icon'],
                        size: 14,
                        color: statusInfo['color'],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusInfo['text'],
                        style: GoogleFonts.poppins(
                          color: statusInfo['color'],
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (statusInfo['detail'] != null) ...[
              const SizedBox(height: 4),
              Text(
                statusInfo['detail']!,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: statusInfo['color'],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Waktu Masuk dan Pulang
            _buildTimeSection(absen, statusInfo['color']),

            // Lokasi (jika ada)
            if ((absen.checkInAddress.isNotEmpty == true) ||
                (absen.checkOutAddress?.isNotEmpty == true))
              _buildLocationSection(absen),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(Datum absen) {
    final checkInTime = absen.checkInTime;
    final checkOutTime = absen.checkOutTime;

    if (absen.alasanIzin != null && absen.alasanIzin.toString().isNotEmpty) {
      return {
        'color': _tidakHadirColor,
        'lightColor': _tidakHadirLightColor,
        'icon': Icons.event_busy,
        'text': 'Tidak Hadir',
        'detail': 'Izin: ${absen.alasanIzin}',
      };
    } else if (checkInTime.isNotEmpty) {
      final checkInDateTime = DateTime.parse('2024-01-01 $checkInTime');
      final eightAM = DateTime(2024, 1, 1, 8, 0);

      if (checkInDateTime.isBefore(eightAM)) {
        return {
          'color': _tepatWaktuColor,
          'lightColor': _tepatWaktuLightColor,
          'icon': Icons.check_circle,
          'text': 'Tepat Waktu',
          'detail': null,
        };
      } else {
        return {
          'color': _terlambatColor,
          'lightColor': _terlambatLightColor,
          'icon': Icons.access_time,
          'text': 'Terlambat',
          'detail': 'Check-in setelah jam 08:00',
        };
      }
    } else {
      return {
        'color': _tidakHadirColor,
        'lightColor': _tidakHadirLightColor,
        'icon': Icons.cancel,
        'text': 'Tidak Hadir',
        'detail': 'Tidak ada check-in',
      };
    }
  }

  Widget _buildTimeSection(Datum absen, Color color) {
    final timeFormat = DateFormat('HH:mm');
    final checkInTime = absen.checkInTime;
    final checkOutTime = absen.checkOutTime;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Kolom Masuk
        _buildTimeItem(
          Icons.login,
          'Masuk',
          checkInTime.isNotEmpty
              ? timeFormat.format(DateTime.parse('2024-01-01 $checkInTime'))
              : '-',
          checkInTime.isNotEmpty ? color : AppColors.neutralGray,
        ),

        // Pembatas
        Container(width: 1, height: 40, color: AppColors.neutralLightGray),

        // Kolom Pulang - SELALU DITAMPILKAN
        _buildTimeItem(
          Icons.logout,
          'Pulang',
          (checkOutTime != null && checkOutTime.isNotEmpty)
              ? timeFormat.format(DateTime.parse('2024-01-01 $checkOutTime'))
              : '-',
          (checkOutTime != null && checkOutTime.isNotEmpty)
              ? color
              : AppColors.neutralGray,
        ),
      ],
    );
  }

  Widget _buildTimeItem(IconData icon, String label, String time, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.neutralGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time == '-' ? '-' : '$time WIB',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(Datum absen) {
    final location = absen.checkInAddress.isNotEmpty == true
        ? absen.checkInAddress
        : absen.checkOutAddress ?? 'Lokasi tidak tersedia';

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on, size: 14, color: AppColors.neutralGray),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              location,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.neutralGray,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
