// lib/features/notifications/data/datasources/push_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PushRemoteDataSource {
  final String baseUrl;

  PushRemoteDataSource({required this.baseUrl});

  Future<void> registerFcmToken({
    required String accessToken,
    required String token,
    required String installationId,
    required String platform,
    required String deviceName,
    required String appVersion,
  }) async {
    final uri = Uri.parse('$baseUrl/api/users/me/fcm-token');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'token': token,
        'installationId': installationId,
        'platform': platform,
        'deviceName': deviceName,
        'appVersion': appVersion,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('No se pudo registrar el token FCM: ${response.body}');
    }
  }

  Future<void> removeFcmToken({
    required String accessToken,
    required String installationId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/users/me/fcm-token');

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'installationId': installationId,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('No se pudo eliminar el token FCM: ${response.body}');
    }
  }
}
