import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/core/config/env.dart';
import 'package:event_app/core/services/socket_service.dart';
import 'package:event_app/features/auth/data/datasource/auth_remote_datasource.dart';

final baseUrlProvider = Provider<String>((ref) => Env.baseUrl);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return AuthRemoteDataSource(baseUrl: baseUrl);
});

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();

  ref.onDispose(() {
    service.disconnect();
  });

  return service;
});