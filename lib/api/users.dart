import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sitikap/api/endpoint/endpoint.dart';
import 'package:sitikap/local/shared_preferenced.dart';
import 'package:sitikap/models/register_model.dart';

class AuthenticationAPI {
  static Future<RegisterModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required File profilePhoto,
    required int batchId,
    required int trainingId,
  }) async {
    final url = Uri.parse(Endpoint.register);

    // Convert foto ke base64
    final bytes = await profilePhoto.readAsBytes();
    final base64Image = base64Encode(bytes);

    // body JSON
    final body = jsonEncode({
      "name": name,
      "email": email,
      "password": password,
      "jenis_kelamin": jenisKelamin,
      "batch_id": batchId,
      "training_id": trainingId,
      "profile_photo": base64Image,
    });

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: body,
    );

    // DEBUG print response
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return registerModelFromJson(response.body);
    } else {
      throw Exception("Failed to register: ${response.body}");
    }
  }

  static Future<RegisterModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);
    final response = await http.post(
      url,
      body: {"email": email, "password": password},
      headers: {"Accept": "application/json"},
    );
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    if (response.statusCode == 200) {
      final data = RegisterModel.fromJson(json.decode(response.body));
      await PreferenceHandler.saveToken(data.data.token);
      await PreferenceHandler.saveLogin();
      return data;
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Register gagal");
    }
  }
}
