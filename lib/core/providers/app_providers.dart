import 'package:event_app/core/services/biometric_service.dart';
import 'package:event_app/core/services/push_registration_service.dart';
import 'package:event_app/core/services/secure_storage_service.dart';
import 'package:event_app/core/services/socket_service.dart';
import 'package:event_app/core/config/env.dart';
import 'package:event_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:event_app/features/notifications/data/datasources/push_remote_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final pushRemoteDataSourceProvider = Provider<PushRemoteDataSource>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return PushRemoteDataSource(baseUrl: baseUrl);
});

final pushRegistrationServiceProvider = Provider<PushRegistrationService>((ref) {
  final remote = ref.watch(pushRemoteDataSourceProvider);
  return PushRegistrationService(remoteDataSource: remote);
});