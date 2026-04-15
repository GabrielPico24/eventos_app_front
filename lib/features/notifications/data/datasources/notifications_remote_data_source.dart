import 'dart:convert';
import 'package:event_app/features/notifications/data/models/notification_model.dart';
import 'package:http/http.dart' as http;

class NotificationsRemoteDataSource {
  final String baseUrl;

  NotificationsRemoteDataSource({required this.baseUrl});

  Future<List<NotificationModel>> getNotifications({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List data = body['data'] ?? [];
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    }

    throw Exception(body['message'] ?? 'Error al listar notificaciones');
  }

  Future<void> sendNotification({
    required String token,
    required String title,
    required String message,
    required String category,
    required bool sendToAll,
    required List<String> userIds,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/notifications/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'message': message,
        'category': category,
        'type': 'info',
        'sendToAll': sendToAll,
        'userIds': userIds,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) return;

    throw Exception(body['message'] ?? 'Error al enviar la notificación');
  }
}