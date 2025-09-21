// To parse this JSON data, do
//
//     final editPotoProfile = editPotoProfileFromJson(jsonString);

import 'dart:convert';

EditPotoProfile editPotoProfileFromJson(String str) =>
    EditPotoProfile.fromJson(json.decode(str));

String editPotoProfileToJson(EditPotoProfile data) =>
    json.encode(data.toJson());

class EditPotoProfile {
  String message;
  Data data;

  EditPotoProfile({required this.message, required this.data});

  factory EditPotoProfile.fromJson(Map<String, dynamic> json) =>
      EditPotoProfile(
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  String profilePhoto;

  Data({required this.profilePhoto});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(profilePhoto: json["profile_photo"]);

  Map<String, dynamic> toJson() => {"profile_photo": profilePhoto};
}
