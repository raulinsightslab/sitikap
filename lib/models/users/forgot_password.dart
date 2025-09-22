// To parse this JSON data, do
//
//     final forgotpassword = forgotpasswordFromJson(jsonString);

import 'dart:convert';

Forgotpassword forgotpasswordFromJson(String str) =>
    Forgotpassword.fromJson(json.decode(str));

String forgotpasswordToJson(Forgotpassword data) => json.encode(data.toJson());

class Forgotpassword {
  String message;

  Forgotpassword({required this.message});

  factory Forgotpassword.fromJson(Map<String, dynamic> json) =>
      Forgotpassword(message: json["message"]);

  Map<String, dynamic> toJson() => {"message": message};
}
