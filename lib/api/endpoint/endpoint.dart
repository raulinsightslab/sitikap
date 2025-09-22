class Endpoint {
  static const String baseURL = "https://appabsensi.mobileprojp.com/api";

  //authentification
  static const String register = "$baseURL/register";
  static const String login = "$baseURL/login";
  static const String trainings = "$baseURL/trainings";
  static const String batches = "$baseURL/batches";
  static const String profile = "$baseURL/profile";
  static const String editProfile = "$baseURL/profile";
  static const String profilePhoto = "$baseURL/profile/photo";

  //absen
  static const String check_in = "$baseURL/absen/check-in";
  static const String check_out = "$baseURL/absen/check-out";
  static const String today = "$baseURL/absen/today";
  static const String history = "$baseURL/absen/history";
  static const String stats = "$baseURL/absen/stats";

  //izin
  static const String izin = "$baseURL/izin";
}
