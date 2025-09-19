// To parse this JSON data, do
//
//     final absenOutmodel = absenOutmodelFromJson(jsonString);

import 'dart:convert';

AbsenOutmodel absenOutmodelFromJson(String str) =>
    AbsenOutmodel.fromJson(json.decode(str));

String absenOutmodelToJson(AbsenOutmodel data) => json.encode(data.toJson());

class AbsenOutmodel {
  String message;
  Data data;

  AbsenOutmodel({required this.message, required this.data});

  factory AbsenOutmodel.fromJson(Map<String, dynamic> json) => AbsenOutmodel(
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  int id;
  DateTime attendanceDate;
  String checkInTime;
  String checkOutTime;
  String checkInAddress;
  String checkOutAddress;
  String checkInLocation;
  String checkOutLocation;
  String status;
  dynamic alasanIzin;

  Data({
    required this.id,
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInAddress,
    required this.checkOutAddress,
    required this.checkInLocation,
    required this.checkOutLocation,
    required this.status,
    required this.alasanIzin,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    attendanceDate: DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkOutTime: json["check_out_time"],
    checkInAddress: json["check_in_address"],
    checkOutAddress: json["check_out_address"],
    checkInLocation: json["check_in_location"],
    checkOutLocation: json["check_out_location"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date":
        "${attendanceDate.year.toString().padLeft(4, '0')}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "check_in_address": checkInAddress,
    "check_out_address": checkOutAddress,
    "check_in_location": checkInLocation,
    "check_out_location": checkOutLocation,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
