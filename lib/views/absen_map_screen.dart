import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sitikap/api/absen_api.dart';
import 'package:sitikap/models/absen/today_model.dart';
import 'package:sitikap/utils/colors.dart';

class AbsenMapScreen extends StatefulWidget {
  const AbsenMapScreen({super.key});

  @override
  State<AbsenMapScreen> createState() => _AbsenMapScreenState();
}

class _AbsenMapScreenState extends State<AbsenMapScreen> {
  GoogleMapController? mapController;
  LatLng? _currentPosition;
  String _currentAddress = "Mencari lokasi...";
  bool isLoading = false;
  AbsenTodayModels? todayAttendance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadTodayAttendance();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentAddress =
              "${place.street}, ${place.subLocality}, ${place.locality}";
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress =
            "Koordinat: ${position.latitude}, ${position.longitude}";
      });
    }
  }

  Future<void> _loadTodayAttendance() async {
    try {
      setState(() => isLoading = true);
      final attendance = await AbsenService.getToday();
      setState(() => todayAttendance = attendance);
    } catch (e) {
      debugPrint("Error load attendance: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitAbsensi({required bool isCheckIn}) async {
    if (_currentPosition == null) return;

    setState(() => isLoading = true);

    final now = DateTime.now();
    final date = DateFormat("yyyy-MM-dd").format(now);
    final time = DateFormat("HH:mm").format(now);

    try {
      if (isCheckIn) {
        await AbsenService.checkIn(
          attendanceDate: date,
          checkIn: time,
          checkInLat: _currentPosition!.latitude,
          checkInLng: _currentPosition!.longitude,
          checkInLocation:
              "${_currentPosition!.latitude}, ${_currentPosition!.longitude}",
          checkInAddress: _currentAddress,
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Absen Masuk Berhasil")));
        }
      } else {
        await AbsenService.checkOut(
          attendanceDate: date,
          checkOut: time,
          checkOutLat: _currentPosition!.latitude,
          checkOutLng: _currentPosition!.longitude,
          checkOutLocation:
              "${_currentPosition!.latitude}, ${_currentPosition!.longitude}",
          checkOutAddress: _currentAddress,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Absen Keluar Berhasil")),
          );
        }
      }

      // refresh data agar status berubah otomatis
      await _loadTodayAttendance();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Absensi gagal: $e")));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkIn = todayAttendance?.data?.checkInTime ?? "--:--";
    final checkOut = todayAttendance?.data?.checkOutTime ?? "--:--";

    // status logic
    final status = checkIn != "--:--" && checkOut == "--:--"
        ? "Masuk"
        : checkOut != "--:--"
        ? "Pulang"
        : "Belum Absen";

    Color statusColor = status == "Masuk"
        ? AppColors.blue
        : status == "Pulang"
        ? AppColors.accentGreen
        : Colors.red;

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
          ),
        ],
      ),
      body: Column(
        children: [
          // MAP
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              height: 250,
              child: _currentPosition == null
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition!,
                          zoom: 16,
                        ),
                        onMapCreated: (c) => mapController = c,
                        markers: {
                          Marker(
                            markerId: const MarkerId("me"),
                            position: _currentPosition!,
                          ),
                        },
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                      ),
                    ),
            ),
          ),

          // STATUS CARD
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        "Status: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.login, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text("Check In: $checkIn"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.logout, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text("Check Out: $checkOut"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentAddress,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (checkIn == "--:--") {
                          _submitAbsensi(isCheckIn: true);
                        } else if (checkOut == "--:--") {
                          _submitAbsensi(isCheckIn: false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (checkIn == "--:--")
                      ? Colors.green
                      : (checkOut == "--:--")
                      ? Colors.orange
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        checkIn == "--:--"
                            ? "Absen Masuk"
                            : checkOut == "--:--"
                            ? "Absen Keluar"
                            : "Absen Selesai",
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
