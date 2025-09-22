import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sitikap/api/absen_api.dart';
import 'package:sitikap/models/absen/history_absen_model.dart';
import 'package:sitikap/utils/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Warna status sesuai permintaan
  final Color _tepatWaktuColor = const Color(0xFF34C759);
  final Color _tepatWaktuLightColor = const Color(0xFF6EFFA0);
  final Color _terlambatColor = const Color(0xFFFFC857);
  final Color _terlambatLightColor = const Color(0xFFFFB84D);
  final Color _tidakHadirColor = const Color(0xFFFF6B6B);
  final Color _tidakHadirLightColor = const Color(0xFFFF7E87);

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
      setState(() {
        if (_selectedStartDate != null && _selectedEndDate != null) {
          // Pastikan startDate lebih kecil dari endDate
          DateTime startDate = _selectedStartDate!;
          DateTime endDate = _selectedEndDate!;

          if (startDate.isAfter(endDate)) {
            // Tukar jika startDate lebih besar dari endDate
            DateTime temp = startDate;
            startDate = endDate;
            endDate = temp;
          }

          _filteredData = riwayatAbsen.data.where((absen) {
            final attendanceDate = absen.attendanceDate;
            // Filter data antara startDate dan endDate (inklusif)
            return (attendanceDate.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ) &&
                attendanceDate.isBefore(endDate.add(const Duration(days: 1))));
          }).toList();
        } else {
          _filteredData = riwayatAbsen.data;
        }
      });
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
      _historyFuture.then((riwayatAbsen) {
        setState(() {
          _filteredData = riwayatAbsen.data;
        });
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
        title: Center(
          child: Text(
            'Riwayat Absensi',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: AppColors.neutralWhite,
        actions: [
          IconButton(
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.primaryDarkBlue,
            ),
            onPressed: _toggleCalendar,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primaryDarkBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          child: Column(
            children: [
              // Kalender Filter
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TableCalendar(
                          firstDay: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDay: DateTime.now().add(
                            const Duration(days: 365),
                          ),
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
                                // Pastikan startDate selalu lebih kecil dari endDate
                                if (_selectedStartDate!.isAfter(
                                  _selectedEndDate!,
                                )) {
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
                              color: AppColors.secondaryBlue,
                              shape: BoxShape.circle,
                            ),
                            rangeStartDecoration: BoxDecoration(
                              color: AppColors.secondaryBlue,
                              shape: BoxShape.circle,
                            ),
                            rangeEndDecoration: BoxDecoration(
                              color: AppColors.secondaryBlue,
                              shape: BoxShape.circle,
                            ),
                            rangeHighlightColor: AppColors.lightBlue,
                            todayTextStyle: GoogleFonts.poppins(
                              color: AppColors.primaryDarkBlue,
                              fontWeight: FontWeight.w600,
                            ),
                            defaultTextStyle: GoogleFonts.poppins(),
                            weekendTextStyle: GoogleFonts.poppins(
                              color: Colors.red,
                            ),
                            outsideTextStyle: GoogleFonts.poppins(
                              color: Colors.grey.shade400,
                            ),
                          ),
                          headerStyle: HeaderStyle(
                            titleTextStyle: GoogleFonts.poppins(
                              color: AppColors.primaryDarkBlue,
                              fontWeight: FontWeight.bold,
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
                        if (_selectedStartDate != null ||
                            _selectedEndDate != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _selectedStartDate != null &&
                                      _selectedEndDate != null
                                  ? 'Filter: ${DateFormat('dd MMM yyyy').format(_selectedStartDate!)} - ${DateFormat('dd MMM yyyy').format(_selectedEndDate!)}'
                                  : _selectedStartDate != null
                                  ? 'Filter: ${DateFormat('dd MMM yyyy').format(_selectedStartDate!)}'
                                  : 'Filter: ${DateFormat('dd MMM yyyy').format(_selectedEndDate!)}',
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryDarkBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            // Tombol Reset Filter dengan gradient outline
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  gradient: AppColors.buttonGradient,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.white,
                                  ),
                                  child: OutlinedButton(
                                    onPressed: _clearFilter,
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor:
                                          AppColors.primaryDarkBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      side: const BorderSide(
                                        color: Colors.transparent,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: Text(
                                      'Reset Filter',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Tombol Terapkan Filter dengan gradient
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.buttonGradient,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: ElevatedButton(
                                  onPressed: _applyDateFilter,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: AppColors.neutralWhite,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: Text(
                                    'Terapkan Filter',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                secondChild: Container(),
              ),

              // Header Status Legend
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusLegend(
                      color: _tepatWaktuColor,
                      text: 'Tepat Waktu',
                    ),
                    _buildStatusLegend(
                      color: _terlambatColor,
                      text: 'Terlambat',
                    ),
                    _buildStatusLegend(
                      color: _tidakHadirColor,
                      text: 'Tidak Hadir',
                    ),
                  ],
                ),
              ),

              // Daftar Riwayat
              FutureBuilder<RiwayatAbsen>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 100),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 100),
                      child: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  } else if (snapshot.hasData) {
                    final data =
                        _selectedStartDate != null && _selectedEndDate != null
                        ? _filteredData
                        : snapshot.data!.data;

                    if (data.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 100),
                        child: Center(
                          child: Text(
                            'Tidak ada data absensi',
                            style: TextStyle(color: AppColors.neutralDarkGray),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final absen = data[index];
                        return _buildAbsenCard(absen);
                      },
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 100),
                      child: Center(child: Text('Tidak ada data')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusLegend({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppColors.neutralDarkGray,
          ),
        ),
      ],
    );
  }

  Widget _buildAbsenCard(Datum absen) {
    final dateFormat = DateFormat('dd MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    final checkInTime = absen.checkInTime;
    final checkOutTime = absen.checkOutTime;

    Color statusColor;
    Color statusLightColor;
    IconData statusIcon;
    String statusText;
    String statusDetail;

    if (absen.alasanIzin != null && absen.alasanIzin.toString().isNotEmpty) {
      statusColor = _tidakHadirColor;
      statusLightColor = _tidakHadirLightColor;
      statusIcon = Icons.event_busy;
      statusText = 'Tidak Hadir';
      statusDetail = 'Izin: ${absen.alasanIzin}';
    } else if (checkInTime.isNotEmpty) {
      final checkInDateTime = DateTime.parse('2024-01-01 $checkInTime');
      final eightAM = DateTime(2024, 1, 1, 8, 0);

      if (checkInDateTime.isBefore(eightAM)) {
        statusColor = _tepatWaktuColor;
        statusLightColor = _tepatWaktuLightColor;
        statusIcon = Icons.check_circle;
        statusText = 'Hadir';
        statusDetail = 'Tepat Waktu';
      } else {
        statusColor = _terlambatColor;
        statusLightColor = _terlambatLightColor;
        statusIcon = Icons.access_time;
        statusText = 'Hadir';
        statusDetail = 'Terlambat';
      }
    } else {
      statusColor = _tidakHadirColor;
      statusLightColor = _tidakHadirLightColor;
      statusIcon = Icons.cancel;
      statusText = 'Tidak Hadir';
      statusDetail = 'Alpha';
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan tanggal dan status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(absen.attendanceDate),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusLightColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: GoogleFonts.poppins(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Status detail
            Text(
              statusDetail,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: statusColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),

            // Waktu Masuk dan Pulang dalam satu baris
            if (checkInTime.isNotEmpty ||
                (checkOutTime != null && checkOutTime!.isNotEmpty))
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (checkInTime.isNotEmpty)
                    _buildTimeColumn(
                      // Icons.login,
                      'Masuk',
                      timeFormat.format(
                        DateTime.parse('2024-01-01 $checkInTime'),
                      ),
                      statusColor,
                    ),

                  if (checkInTime.isNotEmpty &&
                      checkOutTime != null &&
                      checkOutTime!.isNotEmpty)
                    const VerticalDivider(width: 20, thickness: 1),

                  if (checkOutTime != null && checkOutTime!.isNotEmpty)
                    _buildTimeColumn(
                      // Icons.logout,
                      'Pulang',
                      timeFormat.format(
                        DateTime.parse('2024-01-01 $checkOutTime'),
                      ),
                      statusColor,
                    ),
                ],
              ),

            // Lokasi (jika ada)
            if ((absen.checkInAddress?.isNotEmpty == true) ||
                (absen.checkOutAddress?.isNotEmpty == true))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.neutralGray,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        absen.checkInAddress?.isNotEmpty == true
                            ? absen.checkInAddress!
                            : absen.checkOutAddress ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.neutralGray,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(
    // IconData icon,
    String label,
    String time,
    Color color,
  ) {
    return Column(
      children: [
        // Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.neutralGray,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$time WIB',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDarkBlue,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
