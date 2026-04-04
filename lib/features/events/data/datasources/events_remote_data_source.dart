import 'dart:convert';
import 'package:event_app/features/events/data/models/event_model.dart';
import 'package:http/http.dart' as http;

class EventsRemoteDataSource {
  final String baseUrl;

  EventsRemoteDataSource({required this.baseUrl});

  Future<List<EventModel>> getEvents({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/events'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List data = body['data'] ?? [];
      return data.map((e) => EventModel.fromJson(e)).toList();
    }

    if (response.statusCode == 401) {
      print('🔒 HTTP 401 en getEvents -> token expirado');
      throw Exception('401|${body['message'] ?? 'Token inválido o expirado'}');
    }

    throw Exception(body['message'] ?? 'Error al listar eventos');
  }

  Future<List<EventModel>> getMyEvents({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/events/my-events'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List data = body['data'] ?? [];
      return data.map((e) => EventModel.fromJson(e)).toList();
    }

    if (response.statusCode == 401) {
      print('🔒 HTTP 401 en getMyEvents -> token expirado');
      throw Exception('401|${body['message'] ?? 'Token inválido o expirado'}');
    }

    throw Exception(body['message'] ?? 'Error al listar mis eventos');
  }

  Future<void> createEvent({
    required String token,
    required String title,
    required String categoryId,
    required String categoryName,
    required String description,
    required String date,
    required String time,
    required String repeat,
    required bool isActive,
    String status = 'upcoming',
    bool notify24hBefore = true,
    bool notify1hBefore = true,
    bool notifyAtTime = true,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/events'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'category': categoryId,
        'categoryName': categoryName,
        'description': description,
        'date': date,
        'time': time,
        'repeat': repeat,
        'isActive': isActive,
        'status': status,
        'notify24hBefore': notify24hBefore,
        'notify1hBefore': notify1hBefore,
        'notifyAtTime': notifyAtTime,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) return;

    if (response.statusCode == 401) {
      throw Exception('401|${body['message'] ?? 'Token inválido o expirado'}');
    }

    throw Exception(body['message'] ?? 'Error al crear evento');
  }

  Future<void> updateEvent({
    required String token,
    required String id,
    required String title,
    required String categoryId,
    required String categoryName,
    required String description,
    required String date,
    required String time,
    required String repeat,
    required bool isActive,
    String status = 'upcoming',
    bool notify24hBefore = true,
    bool notify1hBefore = true,
    bool notifyAtTime = true,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/events/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'category': categoryId,
        'categoryName': categoryName,
        'description': description,
        'date': date,
        'time': time,
        'repeat': repeat,
        'isActive': isActive,
        'status': status,
        'notify24hBefore': notify24hBefore,
        'notify1hBefore': notify1hBefore,
        'notifyAtTime': notifyAtTime,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) return;

    if (response.statusCode == 401) {
      throw Exception('401|${body['message'] ?? 'Token inválido o expirado'}');
    }

    throw Exception(body['message'] ?? 'Error al actualizar evento');
  }

  Future<void> toggleEventStatus({
    required String token,
    required String id,
    required bool isActive,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/events/$id/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'isActive': isActive,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    if (response.statusCode == 401) {
      print('🔒 HTTP 401 en toggleEventStatus -> token expirado');
      throw Exception('401|${body['message'] ?? 'Token inválido o expirado'}');
    }

    throw Exception(body['message'] ?? 'Error al cambiar estado del evento');
  }
}
