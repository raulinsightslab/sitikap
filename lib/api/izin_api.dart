// izin_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sitikap/api/endpoint/endpoint.dart';
import 'package:sitikap/local/shared_preferenced.dart';
import 'package:sitikap/models/izin/izin_model.dart';

class IzinApiService {
  // Mengajukan izin baru
  static Future<IzinModel> submitIzin({
    required String date,
    required String alasanIzin,
  }) async {
    final url = Uri.parse(Endpoint.izin);
    final token = await PreferenceHandler.getToken();

    final body = jsonEncode({"date": date, "alasan_izin": alasanIzin});

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    // DEBUG print response
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return IzinModel.fromJson(jsonDecode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Gagal mengajukan izin");
    }
  }
}
