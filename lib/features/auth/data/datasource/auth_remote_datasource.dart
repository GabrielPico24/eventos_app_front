import 'dart:convert';
import 'package:event_app/features/auth/data/models/login_response_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final String baseUrl;

  AuthRemoteDataSource({required this.baseUrl});

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return LoginResponseModel.fromJson(body);
    }

    throw Exception(body['message'] ?? 'Error al iniciar sesión');
  }

  Future<String> refreshToken({
    required String refreshToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/refresh'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'refreshToken': refreshToken,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['accessToken'] ?? '';
    }

    throw Exception(body['message'] ?? 'No se pudo renovar la sesión');
  }
}