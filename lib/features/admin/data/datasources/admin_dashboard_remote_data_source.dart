import 'dart:convert';

import 'package:event_app/features/user/presentation/pages/user_home_page.dart';
import 'package:http/http.dart' as http;

class AdminDashboardRemoteDataSource {
  final String baseUrl;

  AdminDashboardRemoteDataSource({
    required this.baseUrl,
  });

  Future<AdminDashboardStats> getDashboardStats({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/dashboard/admin-stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return AdminDashboardStats.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Error al obtener estadísticas');
    }
  }
}