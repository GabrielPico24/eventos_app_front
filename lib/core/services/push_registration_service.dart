// lib/core/services/push_registration_service.dart
import 'dart:async';

import 'package:event_app/features/notifications/data/datasources/push_remote_data_source.dart';
import 'package:event_app/core/services/push_token_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushRegistrationService {
  PushRegistrationService({
    required PushRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final PushRemoteDataSource _remoteDataSource;
  StreamSubscription<String>? _tokenRefreshSub;

  Future<void> initForLoggedUser({
    required String accessToken,
  }) async {
    final settings = await PushTokenService.instance.requestPermissions();

    final authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!authorized) {
      print('🔕 Permisos de notificaciones no concedidos');
      return;
    }

    final token = await PushTokenService.instance.getToken();
    if (token == null || token.isEmpty) {
      print('⚠️ No se pudo obtener token FCM');
      return;
    }

    final installationId =
        await PushTokenService.instance.getOrCreateInstallationId();
    final platform = await PushTokenService.instance.getPlatform();
    final deviceName = await PushTokenService.instance.getDeviceName();
    final appVersion = await PushTokenService.instance.getAppVersion();

    await _remoteDataSource.registerFcmToken(
      accessToken: accessToken,
      token: token,
      installationId: installationId,
      platform: platform,
      deviceName: deviceName,
      appVersion: appVersion,
    );

    print('✅ Token FCM registrado en backend');

    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = PushTokenService.instance.onTokenRefresh.listen(
      (newToken) async {
        try {
          final installationId =
              await PushTokenService.instance.getOrCreateInstallationId();
          final platform = await PushTokenService.instance.getPlatform();
          final deviceName = await PushTokenService.instance.getDeviceName();
          final appVersion = await PushTokenService.instance.getAppVersion();

          await _remoteDataSource.registerFcmToken(
            accessToken: accessToken,
            token: newToken,
            installationId: installationId,
            platform: platform,
            deviceName: deviceName,
            appVersion: appVersion,
          );

          print('🔄 Token FCM actualizado en backend');
        } catch (e) {
          print('❌ Error al refrescar token FCM: $e');
        }
      },
    );
  }

  Future<void> disposeForLogout({
    required String accessToken,
  }) async {
    try {
      final installationId =
          await PushTokenService.instance.getOrCreateInstallationId();

      print('🗑 Eliminando FCM del backend...');
      print('🪪 accessToken => $accessToken');
      print('📱 installationId => $installationId');

      await _remoteDataSource.removeFcmToken(
        accessToken: accessToken,
        installationId: installationId,
      );

      print('✅ Token FCM eliminado del backend');
    } catch (e) {
      print('⚠️ No se pudo eliminar token FCM del backend: $e');
    }

    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
  }
}
