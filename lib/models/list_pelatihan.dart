// To parse this JSON data, do
//
//     final listpelatihan = listpelatihanFromJson(jsonString);

import 'dart:convert';

Listpelatihan listpelatihanFromJson(String str) =>
    Listpelatihan.fromJson(json.decode(str));

String listpelatihanToJson(Listpelatihan data) => json.encode(data.toJson());

class Listpelatihan {
  String message;
  List<Datum> data;

  Listpelatihan({required this.message, required this.data});

  factory Listpelatihan.fromJson(Map<String, dynamic> json) => Listpelatihan(
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  String title;

  Datum({required this.id, required this.title});

  factory Datum.fromJson(Map<String, dynamic> json) =>
      Datum(id: json["id"], title: json["title"]);

  Map<String, dynamic> toJson() => {"id": id, "title": title};
}
