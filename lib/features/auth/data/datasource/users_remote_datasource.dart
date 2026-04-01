import 'dart:convert';
import 'package:event_app/features/auth/data/models/user_model.dart';
import 'package:http/http.dart' as http;

class UsersRemoteDataSource {
  final String baseUrl;

  UsersRemoteDataSource({required this.baseUrl});

  Future<List<UserModel>> getUsers({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List data = body['data'] ?? [];
      return data.map((e) => UserModel.fromJson(e)).toList();
    }

    if (response.statusCode == 401) {
      print('🔒 HTTP 401 en getUsers -> token expirado');
      throw Exception('401|${body['message'] ?? 'Token inválido o expirado'}');
    }

    throw Exception(body['message'] ?? 'Error al listar usuarios');
  }

  Future<UserModel> createUser({
    required String token,
    required String name,
    required String email,
    required String password,
    required String role,
    required bool isActive,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'isActive': isActive,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return UserModel.fromJson(body['data']);
    }

    if (response.statusCode == 401) {
      print('🔒 HTTP 401 en createUser -> token expirado');
      throw Exception('401|${body['message'] ?? 'Token inválido o expirado'}');
    }

    throw Exception(body['message'] ?? 'Error al crear usuario');
  }

  Future<UserModel> updateUser({
    required String token,
    required String id,
    required String name,
    required String email,
    required String password,
    required String role,
    required bool isActive,
  }) async {
    final bodyMap = {
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
    };

    if (password.trim().isNotEmpty) {
      bodyMap['password'] = password.trim();
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(bodyMap),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return UserModel.fromJson(body['data']);
    }

    if (response.statusCode == 401) {
      print('🔒 HTTP 401 en updateUser -> token expirado');
      throw Exception('401|${body['message'] ?? 'Token inválido o expirado'}');
    }

    throw Exception(body['message'] ?? 'Error al editar usuario');
  }

  Future<void> deleteUser({
    required String token,
    required String id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    Map<String, dynamic> body = {};
    if (response.body.isNotEmpty) {
      body = jsonDecode(response.body);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    if (response.statusCode == 401) {
      print('🔒 HTTP 401 en deleteUser -> token expirado');
      throw Exception('401|${body['message'] ?? 'Token inválido o expirado'}');
    }

    throw Exception(body['message'] ?? 'Error al eliminar usuario');
  }
}