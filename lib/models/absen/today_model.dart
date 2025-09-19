// To parse this JSON data, do
//
//     final absenToday = absenTodayFromJson(jsonString);

import 'dart:convert';

AbsenToday absenTodayFromJson(String str) =>
    AbsenToday.fromJson(json.decode(str));

String absenTodayToJson(AbsenToday data) => json.encode(data.toJson());

class AbsenToday {
  String message;
  Data1 data;

  AbsenToday({required this.message, required this.data});

  factory AbsenToday.fromJson(Map<String, dynamic> json) =>
      AbsenToday(message: json["message"], data: Data1.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data1 {
  DateTime attendanceDate;
  String checkInTime;
  dynamic checkOutTime;
  String checkInAddress;
  dynamic checkOutAddress;
  String status;
  dynamic alasanIzin;

  Data1({
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInAddress,
    required this.checkOutAddress,
    required this.status,
    required this.alasanIzin,
  });

  factory Data1.fromJson(Map<String, dynamic> json) => Data1(
    attendanceDate: DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkOutTime: json["check_out_time"],
    checkInAddress: json["check_in_address"],
    checkOutAddress: json["check_out_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "attendance_date":
        "${attendanceDate.year.toString().padLeft(4, '0')}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "check_in_address": checkInAddress,
    "check_out_address": checkOutAddress,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
