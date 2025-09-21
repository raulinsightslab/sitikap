import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sitikap/api/endpoint/endpoint.dart';
import 'package:sitikap/local/shared_preferenced.dart';
import 'package:sitikap/models/absen/check_in.dart';
import 'package:sitikap/models/absen/check_out.dart';
import 'package:sitikap/models/absen/history_absen_model.dart';
import 'package:sitikap/models/absen/today_model.dart';

class AbsenService {
  // Headers dengan authorization - DIBUAT STATIC
  static Map<String, String> _getHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Check In - STATIC
  static Future<AbsenInmodel> checkIn({
    required String attendanceDate,
    required String checkIn,
    required double checkInLat,
    required double checkInLng,
    required String checkInLocation,
    required String checkInAddress,
  }) async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final response = await http.post(
        Uri.parse(Endpoint.check_in),
        headers: _getHeaders(token),
        body: json.encode({
          "attendance_date": attendanceDate,
          "check_in": checkIn,
          "check_in_lat": checkInLat,
          "check_in_lng": checkInLng,
          "check_in_location": checkInLocation,
          "check_in_address": checkInAddress,
        }),
      );

      // DEBUG print response
      print("Check In Status: ${response.statusCode}");
      print("Check In Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AbsenInmodelFromJson(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error["message"] ?? "Gagal check in: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception('Check in error: $e');
    }
  }

  // Check Out - STATIC
  static Future<AbsenOutmodel> checkOut({
    required String attendanceDate,
    required String checkOut,
    required double checkOutLat,
    required double checkOutLng,
    required String checkOutLocation,
    required String checkOutAddress,
  }) async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final response = await http.post(
        Uri.parse(Endpoint.check_out),
        headers: _getHeaders(token),
        body: json.encode({
          "attendance_date": attendanceDate,
          "check_out": checkOut,
          "check_out_lat": checkOutLat,
          "check_out_lng": checkOutLng,
          "check_out_location": checkOutLocation,
          "check_out_address": checkOutAddress,
        }),
      );

      // DEBUG print response
      print("Check Out Status: ${response.statusCode}");
      print("Check Out Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return absenOutmodelFromJson(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error["message"] ?? "Gagal check out: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception('Check out error: $e');
    }
  }

  // Get Today's Attendance - STATIC (DIPERBAIKI)
  static Future<AbsenToday> getAbsenToday() async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final response = await http.get(
        Uri.parse(Endpoint.today), // PASTIKAN INI ENDPOINT YANG BENAR
        headers: _getHeaders(token),
      );

      // DEBUG print response
      print("Today Status: ${response.statusCode}");
      print("Today Response: ${response.body}");

      if (response.statusCode == 200) {
        return absenTodayFromJson(response.body);
      } else if (response.statusCode == 404) {
        // Handle case ketika tidak ada data absensi hari ini
        return AbsenToday(
          message: "Tidak ada absensi hari ini",
          data: Data1(
            attendanceDate: DateTime.now(),
            checkInTime: "",
            checkOutTime: null,
            checkInAddress: "",
            checkOutAddress: null,
            status: "belum_absen",
            alasanIzin: null,
          ),
        );
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error["message"] ?? "Gagal mengambil data absensi hari ini",
        );
      }
    } catch (e) {
      throw Exception('Get today attendance error: $e');
    }
  }

  // Tambahkan di absen_api.dart
  // Dalam file absen_api.dart - MODIFIKASI METHOD getHistory()
  static Future<RiwayatAbsen> getHistory() async {
    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) throw Exception("Token tidak ditemukan");

      final response = await http.get(
        Uri.parse(Endpoint.history),
        headers: _getHeaders(token),
      );

      print("History Status: ${response.statusCode}");
      print("History Response: ${response.body}");

      if (response.statusCode == 200) {
        // Handle parsing dengan lebih aman
        final responseData = json.decode(response.body);

        // Pastikan structure response sesuai expectasi
        if (responseData is! Map<String, dynamic>) {
          throw Exception("Format response tidak valid");
        }

        final message = responseData['message'] ?? 'Success';
        final dataList = responseData['data'] as List? ?? [];

        // Convert each item dengan handle null values
        final List<Datum> data = dataList.map((item) {
          if (item is! Map<String, dynamic>) {
            throw Exception("Format data item tidak valid");
          }

          return Datum(
            id: item['id'] as int? ?? 0,
            attendanceDate: item['attendance_date'] != null
                ? DateTime.parse(item['attendance_date'].toString())
                : DateTime.now(),
            checkInTime:
                item['check_in_time']?.toString() ??
                "", // Empty string instead of null
            checkOutTime: item['check_out_time']?.toString(),
            checkInLat: (item['check_in_lat'] as num?)?.toDouble() ?? 0.0,
            checkInLng: (item['check_in_lng'] as num?)?.toDouble() ?? 0.0,
            checkOutLat: (item['check_out_lat'] as num?)?.toDouble(),
            checkOutLng: (item['check_out_lng'] as num?)?.toDouble(),
            checkInAddress:
                item['check_in_address']?.toString() ?? "", // Empty string
            checkOutAddress: item['check_out_address']?.toString(),
            checkInLocation:
                item['check_in_location']?.toString() ?? "", // Empty string
            checkOutLocation: item['check_out_location']?.toString(),
            status: item['status']?.toString() ?? "unknown", // Default value
            alasanIzin: item['alasan_izin'],
          );
        }).toList();

        return RiwayatAbsen(message: message, data: data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error["message"] ?? "Gagal mengambil riwayat absensi");
      }
    } catch (e) {
      print("Get history error details: $e");
      throw Exception('Get history error: $e');
    }
  }
  // static Future<RiwayatAbsen> getHistory() async {
  //   try {
  //     final token = await PreferenceHandler.getToken();
  //     if (token == null) throw Exception("Token tidak ditemukan");

  //     final response = await http.get(
  //       Uri.parse(
  //         Endpoint.history,
  //       ), // Pastikan endpoint ini sudah didefinisikan
  //       headers: _getHeaders(token),
  //     );

  //     print("History Status: ${response.statusCode}");
  //     print("History Response: ${response.body}");

  //     if (response.statusCode == 200) {
  //       return riwayatAbsenFromJson(response.body);
  //     } else {
  //       final error = json.decode(response.body);
  //       throw Exception(error["message"] ?? "Gagal mengambil riwayat absensi");
  //     }
  //   } catch (e) {
  //     throw Exception('Get history error: $e');
  //   }
  // }
}
