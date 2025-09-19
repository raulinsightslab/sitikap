import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sitikap/api/absen_api.dart';
import 'package:sitikap/models/absen/today_model.dart';

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
  String _currentAddress = "Alamat tidak ditemukan";
  Marker? _marker;
  bool isLoading = false;
  AbsenToday? todayAttendance;
  bool canCheckIn = true;
  bool canCheckOut = false;

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
    try {
      setState(() => isLoading = true);
      final attendance = await AbsenService.getAbsenToday();

      if (!mounted) return;
      setState(() {
        todayAttendance = attendance;
        canCheckIn = attendance.data.checkInTime.isEmpty;
        canCheckOut =
            attendance.data.checkInTime.isNotEmpty &&
            attendance.data.checkOutTime == null;
      });
    } catch (e) {
      print("Error loading today attendance: $e");
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

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
        _currentPosition.latitude,
        _currentPosition.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _marker = Marker(
            markerId: MarkerId("lokasi_saya"),
            position: _currentPosition,
            infoWindow: InfoWindow(
              title: 'Lokasi Anda',
              snippet: "${place.street}, ${place.locality}",
            ),
          );

          _currentAddress =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}";
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
            "Lokasi: ${_currentPosition.latitude.toStringAsFixed(6)}, ${_currentPosition.longitude.toStringAsFixed(6)}";
      });
    }
  }

  Future<void> _handleCheckIn() async {
    try {
      if (!mounted) return;
      setState(() => isLoading = true);

      final now = DateTime.now();
      final result = await AbsenService.checkIn(
        attendanceDate:
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
        checkIn:
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
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
    try {
      if (!mounted) return;
      setState(() => isLoading = true);

      final now = DateTime.now();
      final result = await AbsenService.checkOut(
        attendanceDate:
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
        checkOut:
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
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

  Future<void> _onMapTap(LatLng position) async {
    try {
      if (!mounted) return;
      setState(() => isLoading = true);

      final pos = Position(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      await _updateLocation(pos);
    } catch (e) {
      print("Error updating location: $e");
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Absensi Lokasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 12,
                  ),
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  onTap: _onMapTap,
                  markers: _marker != null ? {_marker!} : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lokasi Terpilih:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(_currentAddress, style: TextStyle(fontSize: 14)),
                    SizedBox(height: 8),
                    Text(
                      'Koordinat: ${lat.toStringAsFixed(6)}, ${long.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    if (todayAttendance != null) ...[
                      Text(
                        'Status Hari Ini:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Check In: ${todayAttendance!.data.checkInTime.isNotEmpty ? todayAttendance!.data.checkInTime : "Belum"}',
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.logout, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Check Out: ${todayAttendance!.data.checkOutTime ?? "Belum"}',
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: canCheckIn && !isLoading
                                ? _handleCheckIn
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('CHECK IN'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: canCheckOut && !isLoading
                                ? _handleCheckOut
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('CHECK OUT'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: Icon(Icons.my_location),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
