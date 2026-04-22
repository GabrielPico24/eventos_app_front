import 'package:event_app/features/admin/data/models/admin_dashboard_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/core/providers/app_providers.dart';
import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:event_app/features/admin/data/datasources/admin_dashboard_remote_data_source.dart';

final adminDashboardRemoteDataSourceProvider =
    Provider<AdminDashboardRemoteDataSource>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return AdminDashboardRemoteDataSource(baseUrl: baseUrl);
});

final adminDashboardStatsProvider =
    FutureProvider<AdminDashboardStats>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final token = authState.token;

  if (token == null || token.isEmpty) {
    throw Exception('Token no disponible');
  }

  final remote = ref.watch(adminDashboardRemoteDataSourceProvider);

  return remote.getDashboardStats(token: token);
});