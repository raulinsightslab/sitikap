import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sitikap/api/absen_api.dart';
import 'package:sitikap/models/absen/today_model.dart';
import 'package:sitikap/utils/colors.dart';
import 'package:intl/intl.dart';

class AbsenMapScreen extends StatefulWidget {
  const AbsenMapScreen({super.key});

  @override
  State<AbsenMapScreen> createState() => _AbsenMapScreenState();
}

class _AbsenMapScreenState extends State<AbsenMapScreen> {
  GoogleMapController? mapController;
  LatLng _currentPosition = LatLng(-6.200000, 106.816666);
  double lat = -6.200000;
  double long = 106.816666;
  String _currentAddress = "Mencari lokasi...";
  Marker? _marker;
  bool isLoading = false;
  AbsenTodayModels? todayAttendance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadTodayAttendance();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadTodayAttendance() async {
    if (!mounted) return;

    try {
      setState(() => isLoading = true);
      final attendance = await AbsenService.getToday();

      if (!mounted) return;
      setState(() => todayAttendance = attendance);
    } catch (e) {
      print("Error loading today attendance: $e");
      if (!mounted) return;
      // Optional: Tampilkan snackbar error jika diperlukan
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      await _updateLocation(position);
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  Future<void> _updateLocation(Position position) async {
    if (!mounted) return;

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      lat = position.latitude;
      long = position.longitude;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _marker = Marker(
            markerId: const MarkerId("lokasi_saya"),
            position: _currentPosition,
          );
          _currentAddress =
              "${place.street}, ${place.subLocality}, ${place.locality}";
        });

        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition, zoom: 16),
          ),
        );
      }
    } catch (e) {
      print("Error getting address: $e");
      if (!mounted) return;
      setState(() {
        _currentAddress =
            "Lokasi: ${lat.toStringAsFixed(6)}, ${long.toStringAsFixed(6)}";
      });
    }
  }

  Future<void> _handleCheckIn() async {
    if (!mounted) return;

    try {
      setState(() => isLoading = true);

      final now = DateTime.now();
      final date = DateFormat("yyyy-MM-dd").format(now);
      final time = DateFormat("HH:mm").format(now);

      final result = await AbsenService.checkIn(
        attendanceDate: date,
        checkIn: time,
        checkInLat: lat,
        checkInLng: long,
        checkInLocation:
            "${lat.toStringAsFixed(6)}, ${long.toStringAsFixed(6)}",
        checkInAddress: _currentAddress,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));

      await _loadTodayAttendance();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal check in: $e")));
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleCheckOut() async {
    if (!mounted) return;

    try {
      setState(() => isLoading = true);

      final now = DateTime.now();
      final date = DateFormat("yyyy-MM-dd").format(now);
      final time = DateFormat("HH:mm").format(now);

      final result = await AbsenService.checkOut(
        attendanceDate: date,
        checkOut: time,
        checkOutLat: lat,
        checkOutLng: long,
        checkOutLocation:
            "${lat.toStringAsFixed(6)}, ${long.toStringAsFixed(6)}",
        checkOutAddress: _currentAddress,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));

      await _loadTodayAttendance();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal check out: $e")));
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Data dari API getToday (sesuai contoh Postman)
    final checkInTime = todayAttendance?.data?.checkInTime;
    final checkOutTime = todayAttendance?.data?.checkOutTime;

    // Tentukan status tombol berdasarkan data API
    final hasCheckedIn = checkInTime != null && checkInTime.isNotEmpty;
    final hasCheckedOut = checkOutTime != null && checkOutTime.isNotEmpty;

    String buttonText = "Absen Masuk";
    Color buttonColor = AppColors.blue;
    bool showButton = true;

    if (hasCheckedIn && !hasCheckedOut) {
      buttonText = "Absen Keluar";
      buttonColor = Colors.orange;
    } else if (hasCheckedOut) {
      buttonText = "Absen Selesai";
      buttonColor = Colors.grey;
      showButton = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Absensi Lokasi',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.neutralWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTodayAttendance,
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: Column(
        children: [
          // PETA KOTAK KECIL
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 16,
                ),
                onMapCreated: (controller) => mapController = controller,
                markers: _marker != null ? {_marker!} : {},
                myLocationEnabled: true,
                zoomControlsEnabled: false,
              ),
            ),
          ),

          // CARD STATUS
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status Hari Ini:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: hasCheckedIn ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Check In',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            checkInTime ?? "--:--",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: hasCheckedIn ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.logout,
                        size: 20,
                        color: hasCheckedOut ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Check Out',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            checkOutTime ?? "--:--",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: hasCheckedOut ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (todayAttendance?.data?.status != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.info, size: 20, color: Colors.blue),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              todayAttendance!.data!.status!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // CARD LOKASI
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokasi Saat Ini:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentAddress,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Koordinat: ${lat.toStringAsFixed(6)}, ${long.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // TOMBOL ABSEN
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: showButton && !isLoading
                    ? () {
                        if (!hasCheckedIn) {
                          _handleCheckIn();
                        } else if (hasCheckedIn && !hasCheckedOut) {
                          _handleCheckOut();
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
