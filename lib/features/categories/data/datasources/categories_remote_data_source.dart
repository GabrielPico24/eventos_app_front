import 'dart:convert';
import 'package:event_app/features/categories/data/models/category_model.dart';
import 'package:http/http.dart' as http;

class CategoriesRemoteDataSource {
  final String baseUrl;

  CategoriesRemoteDataSource({
    required this.baseUrl,
  });

  Future<List<CategoryModel>> getCategories({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/categories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List data = body['data'] ?? [];
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    }

    if (response.statusCode == 401) {
      print('🔒 HTTP 401 en getCategories -> token expirado');
      throw Exception('401|${body['message'] ?? 'Token inválido o expirado'}');
    }

    throw Exception(body['message'] ?? 'Error al listar categorías');
  }

  Future<CategoryModel> createCategory({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/categories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return CategoryModel.fromJson(body['data']);
    }

    if (response.statusCode == 401) {
      print('🔒 HTTP 401 en createCategory -> token expirado');
      throw Exception('401|${body['message'] ?? 'Token inválido o expirado'}');
    }

    throw Exception(body['message'] ?? 'Error al crear categoría');
  }

  Future<CategoryModel> updateCategory({
    required String token,
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/categories/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return CategoryModel.fromJson(body['data']);
    }

    if (response.statusCode == 401) {
      print('🔒 HTTP 401 en updateCategory -> token expirado');
      throw Exception('401|${body['message'] ?? 'Token inválido o expirado'}');
    }

    throw Exception(body['message'] ?? 'Error al actualizar categoría');
  }

  Future<void> deleteCategory({
    required String token,
    required String id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/categories/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    if (response.statusCode == 401) {
      print('🔒 HTTP 401 en deleteCategory -> token expirado');
      throw Exception('401|${body['message'] ?? 'Token inválido o expirado'}');
    }

    throw Exception(body['message'] ?? 'Error al eliminar categoría');
  }
}