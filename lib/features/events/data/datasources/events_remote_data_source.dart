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

    throw Exception(body['message'] ?? 'Error al listar eventos');
  }

  Future<void> createEvent({
    required String token,
    required String title,
    required String categoryId,
    required String description,
    required String date,
    required String time,
    required bool isActive,
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
        'description': description,
        'date': date,
        'time': time,
        'isActive': isActive,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Error al crear evento');
    }
  }

  Future<void> updateEvent({
    required String token,
    required String id,
    required String title,
    required String categoryId,
    required String description,
    required String date,
    required String time,
    required bool isActive,
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
        'description': description,
        'date': date,
        'time': time,
        'isActive': isActive,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Error al actualizar evento');
    }
  }

  Future<void> deleteEvent({
    required String token,
    required String id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/events/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'Error al eliminar evento');
    }
  }
}