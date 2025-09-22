// To parse this JSON data, do
//
//     final resetpw = resetpwFromJson(jsonString);

import 'dart:convert';

Resetpw resetpwFromJson(String str) => Resetpw.fromJson(json.decode(str));

String resetpwToJson(Resetpw data) => json.encode(data.toJson());

class Resetpw {
  String message;

  Resetpw({required this.message});

  factory Resetpw.fromJson(Map<String, dynamic> json) =>
      Resetpw(message: json["message"]);

  Map<String, dynamic> toJson() => {"message": message};
}
