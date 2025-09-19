// To parse this JSON data, do
//
//     final getuser = getuserFromJson(jsonString);

import 'dart:convert';

Getuser getuserFromJson(String str) => Getuser.fromJson(json.decode(str));

String getuserToJson(Getuser data) => json.encode(data.toJson());

class Getuser {
  String message;
  Data data;

  Getuser({required this.message, required this.data});

  factory Getuser.fromJson(Map<String, dynamic> json) =>
      Getuser(message: json["message"], data: Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  int id;
  String name;
  String email;
  String batchKe;
  String trainingTitle;
  Batch batch;
  Training training;
  String jenisKelamin;
  String profilePhoto;
  String profilePhotoUrl;

  Data({
    required this.id,
    required this.name,
    required this.email,
    required this.batchKe,
    required this.trainingTitle,
    required this.batch,
    required this.training,
    required this.jenisKelamin,
    required this.profilePhoto,
    required this.profilePhotoUrl,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    batchKe: json["batch_ke"],
    trainingTitle: json["training_title"],
    batch: Batch.fromJson(json["batch"]),
    training: Training.fromJson(json["training"]),
    jenisKelamin: json["jenis_kelamin"],
    profilePhoto: json["profile_photo"],
    profilePhotoUrl: json["profile_photo_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "batch_ke": batchKe,
    "training_title": trainingTitle,
    "batch": batch.toJson(),
    "training": training.toJson(),
    "jenis_kelamin": jenisKelamin,
    "profile_photo": profilePhoto,
    "profile_photo_url": profilePhotoUrl,
  };
}

class Batch {
  int id;
  String batchKe;
  DateTime startDate;
  DateTime endDate;
  DateTime createdAt;
  DateTime updatedAt;

  Batch({
    required this.id,
    required this.batchKe,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
    id: json["id"],
    batchKe: json["batch_ke"],
    startDate: DateTime.parse(json["start_date"]),
    endDate: DateTime.parse(json["end_date"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "batch_ke": batchKe,
    "start_date":
        "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
    "end_date":
        "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class Training {
  int id;
  String title;
  dynamic description;
  dynamic participantCount;
  dynamic standard;
  dynamic duration;
  DateTime createdAt;
  DateTime updatedAt;

  Training({
    required this.id,
    required this.title,
    required this.description,
    required this.participantCount,
    required this.standard,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Training.fromJson(Map<String, dynamic> json) => Training(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    participantCount: json["participant_count"],
    standard: json["standard"],
    duration: json["duration"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "participant_count": participantCount,
    "standard": standard,
    "duration": duration,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
