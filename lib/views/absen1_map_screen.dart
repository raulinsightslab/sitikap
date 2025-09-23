import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sitikap/api/absen_api.dart';
import 'package:sitikap/models/absen/today_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AbsenScreen extends StatefulWidget {
  const AbsenScreen({Key? key}) : super(key: key);

  @override
  State<AbsenScreen> createState() => _AbsenScreenState();
}

class _AbsenScreenState extends State<AbsenScreen> {
  // State variables
  bool _isLoading = true;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;
  AbsenTodayModels? _todayData;
  String _errorMessage = '';
  Position? _currentPosition;
  String _currentAddress = 'Mendapatkan lokasi...';

  @override
  void initState() {
    super.initState();
    _loadTodayData();
    _getCurrentLocation();
  }

  // Load today's attendance data
  Future<void> _loadTodayData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final todayData = await AbsenService.getToday();
      setState(() {
        _todayData = todayData;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data absen: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    try {
      // Check permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Layanan lokasi tidak aktif';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = 'Izin lokasi ditolak';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = 'Izin lokasi ditolak permanen';
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      String address =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}';

      setState(() {
        _currentPosition = position;
        _currentAddress = address;
      });
    } catch (e) {
      setState(() {
        _currentAddress = 'Gagal mendapatkan lokasi: $e';
      });
    }
  }

  // Check In function
  Future<void> _checkIn() async {
    if (_currentPosition == null) {
      _showErrorDialog(
        'Lokasi tidak tersedia. Harap tunggu atau refresh lokasi.',
      );
      return;
    }

    setState(() {
      _isCheckingIn = true;
    });

    try {
      final now = DateTime.now();
      final attendanceDate = DateFormat('yyyy-MM-dd').format(now);
      final checkInTime = DateFormat('HH:mm').format(now);

      await AbsenService.checkIn(
        attendanceDate: attendanceDate,
        checkIn: checkInTime,
        checkInLat: _currentPosition!.latitude,
        checkInLng: _currentPosition!.longitude,
        checkInLocation: 'Lokasi Check-In',
        checkInAddress: _currentAddress,
      );

      // Refresh data setelah check in berhasil
      await _loadTodayData();

      _showSuccessDialog('Check In berhasil pukul $checkInTime');
    } catch (e) {
      _showErrorDialog('Gagal Check In: $e');
    } finally {
      setState(() {
        _isCheckingIn = false;
      });
    }
  }

  // Check Out function
  Future<void> _checkOut() async {
    if (_currentPosition == null) {
      _showErrorDialog(
        'Lokasi tidak tersedia. Harap tunggu atau refresh lokasi.',
      );
      return;
    }

    setState(() {
      _isCheckingOut = true;
    });

    try {
      final now = DateTime.now();
      final attendanceDate = DateFormat('yyyy-MM-dd').format(now);
      final checkOutTime = DateFormat('HH:mm').format(now);

      await AbsenService.checkOut(
        attendanceDate: attendanceDate,
        checkOut: checkOutTime,
        checkOutLat: _currentPosition!.latitude,
        checkOutLng: _currentPosition!.longitude,
        checkOutLocation: 'Lokasi Check-Out',
        checkOutAddress: _currentAddress,
      );

      // Refresh data setelah check out berhasil
      await _loadTodayData();

      _showSuccessDialog('Check Out berhasil pukul $checkOutTime');
    } catch (e) {
      _showErrorDialog('Gagal Check Out: $e');
    } finally {
      setState(() {
        _isCheckingOut = false;
      });
    }
  }

  // Show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sukses'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Build status card
  Widget _buildStatusCard() {
    final data = _todayData?.data;

    if (data == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.schedule, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'Belum ada absensi hari ini',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(data.status),
                  color: _getStatusColor(data.status),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status: ${_getStatusText(data.status)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getStatusColor(data.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (data.checkInTime != null && data.checkInTime!.isNotEmpty)
              _buildInfoRow('Check In', data.checkInTime!),
            if (data.checkOutTime != null && data.checkOutTime!.isNotEmpty)
              _buildInfoRow('Check Out', data.checkOutTime!),
            if (data.checkInAddress != null && data.checkInAddress!.isNotEmpty)
              _buildInfoRow('Lokasi Check In', data.checkInAddress!),
            if (data.checkOutAddress != null &&
                data.checkOutAddress!.isNotEmpty)
              _buildInfoRow('Lokasi Check Out', data.checkOutAddress!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'masuk':
        return Icons.check_circle;
      case 'izin':
        return Icons.info;
      case 'sakit':
        return Icons.medical_services;
      default:
        return Icons.schedule;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'masuk':
        return Colors.green;
      case 'izin':
        return Colors.orange;
      case 'sakit':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    return status?.toUpperCase() ?? 'BELUM ABSEN';
  }

  // Build action buttons
  Widget _buildActionButtons() {
    final data = _todayData?.data;
    final hasCheckedIn =
        data?.checkInTime != null && data!.checkInTime!.isNotEmpty;
    final hasCheckedOut =
        data?.checkOutTime != null && data!.checkOutTime!.isNotEmpty;

    return Column(
      children: [
        if (!hasCheckedIn || !hasCheckedOut) ...[
          Text(
            'Lokasi Saat Ini:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentAddress,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _getCurrentLocation,
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (!hasCheckedIn)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCheckingIn ? null : _checkIn,
              icon: const Icon(Icons.login),
              label: _isCheckingIn
                  ? const CircularProgressIndicator()
                  : const Text('CHECK IN'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),

        if (hasCheckedIn && !hasCheckedOut) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCheckingOut ? null : _checkOut,
              icon: const Icon(Icons.logout),
              label: _isCheckingOut
                  ? const CircularProgressIndicator()
                  : const Text('CHECK OUT'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],

        if (hasCheckedIn && hasCheckedOut)
          Card(
            color: Colors.green[50],
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Absensi hari ini sudah selesai',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTodayData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat(
                                  'EEEE, d MMMM yyyy',
                                ).format(DateTime.now()),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                DateFormat('HH:mm').format(DateTime.now()),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status Card
                  _buildStatusCard(),

                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),

                  // Error Message
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
