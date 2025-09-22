// To parse this JSON data, do
//
//     final editPotoProfile = editPotoProfileFromJson(jsonString);

import 'dart:convert';

EditPotoProfile editPotoProfileFromJson(String str) =>
    EditPotoProfile.fromJson(json.decode(str));

String editPotoProfileToJson(EditPotoProfile data) =>
    json.encode(data.toJson());

class EditPotoProfile {
  String? message;
  Data? data;

  EditPotoProfile({this.message, this.data});

  factory EditPotoProfile.fromJson(Map<String, dynamic> json) =>
      EditPotoProfile(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  String? profilePhoto;

  Data({this.profilePhoto});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(profilePhoto: json["profile_photo"]);

  Map<String, dynamic> toJson() => {"profile_photo": profilePhoto};
}
