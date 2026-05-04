// lib/core/services/push_notification_service.dart

import 'dart:async';
import 'dart:convert';

import 'package:event_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  if (kDebugMode) {
    print('🔔 PUSH RECIBIDA EN BACKGROUND / TERMINATED');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }

  /*
    IMPORTANTE:
    No mostramos notificación local aquí para evitar duplicados.

    Cuando la app está en background/terminated y el backend envía:
    notification: { title, body }

    Android/iOS muestran la notificación automáticamente.
  */
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _pushChannelId = 'event_push_channel';
  static const String _pushChannelName = 'Eventos';
  static const String _pushChannelDescription =
      'Notificaciones push de la aplicación de eventos';

  bool _initialized = false;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedFromBackgroundSub;

  Future<void> init({
    required Future<void> Function(Map<String, dynamic> data) onNotificationTap,
  }) async {
    if (_initialized) {
      if (kDebugMode) {
        print('ℹ️ PushNotificationService ya estaba inicializado');
      }
      return;
    }

    _initialized = true;

    await _requestFirebasePermission();
    await _initLocalPushNotifications(onNotificationTap);
    await _configureForegroundPresentation();

    _listenForegroundMessages();
    _listenOpenedFromBackground(onNotificationTap);
    await _listenOpenedFromTerminated(onNotificationTap);

    if (kDebugMode) {
      print('✅ PushNotificationService inicializado correctamente');
    }
  }

  Future<void> _requestFirebasePermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    if (kDebugMode) {
      print('🔐 Permiso Firebase Messaging: ${settings.authorizationStatus}');
    }
  }

  Future<void> _initLocalPushNotifications(
    Future<void> Function(Map<String, dynamic> data) onNotificationTap,
  ) async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;

        if (payload == null || payload.trim().isEmpty) {
          if (kDebugMode) {
            print('⚠️ Push local tocada sin payload');
          }
          return;
        }

        try {
          final decoded = jsonDecode(payload);

          if (decoded is Map<String, dynamic>) {
            await onNotificationTap(decoded);
          } else if (decoded is Map) {
            await onNotificationTap(
              decoded.map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error leyendo payload push local: $e');
            print('Payload recibido: $payload');
          }
        }
      },
    );

    final android = _localPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _pushChannelId,
        _pushChannelName,
        description: _pushChannelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );

    if (kDebugMode) {
      print('✅ Canal push Android creado: $_pushChannelId');
    }
  }

  Future<void> _configureForegroundPresentation() async {
    /*
      En iOS, si dejamos alert:true y también mostramos una local,
      pueden salir duplicadas.

      Por eso dejamos alert:false y mostramos nosotros UNA local
      desde onMessage.
    */
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );
  }

  void _listenForegroundMessages() {
    _foregroundSub?.cancel();

    _foregroundSub = FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        if (kDebugMode) {
          print('🔔 PUSH RECIBIDA EN PRIMER PLANO');
          print('Notification title: ${message.notification?.title}');
          print('Notification body: ${message.notification?.body}');
          print('Data: ${message.data}');
        }

        final title = message.notification?.title ??
            message.data['title']?.toString() ??
            'Agenda Eventos';

        final body = message.notification?.body ??
            message.data['body']?.toString() ??
            message.data['message']?.toString() ??
            'Tienes una nueva notificación';

        final payloadData = <String, dynamic>{
          ...message.data,
          'title': title,
          'body': body,
        };

        final notificationId = _buildPushNotificationId(message);

        await showForegroundLocalNotification(
          id: notificationId,
          title: title,
          body: body,
          data: payloadData,
        );
      },
    );
  }

  Future<void> showForegroundLocalNotification({
    required int id,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    await _localPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _pushChannelId,
          _pushChannelName,
          channelDescription: _pushChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(data),
    );
  }

  void _listenOpenedFromBackground(
    Future<void> Function(Map<String, dynamic> data) onNotificationTap,
  ) {
    _openedFromBackgroundSub?.cancel();

    _openedFromBackgroundSub = FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {
        if (kDebugMode) {
          print('📲 APP ABIERTA DESDE SEGUNDO PLANO POR PUSH');
          print('Data: ${message.data}');
        }

        await onNotificationTap(_normalizeMessageData(message));
      },
    );
  }

  Future<void> _listenOpenedFromTerminated(
    Future<void> Function(Map<String, dynamic> data) onNotificationTap,
  ) async {
    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage == null) return;

    if (kDebugMode) {
      print('📲 APP ABIERTA DESDE CERRADA POR PUSH');
      print('Data: ${initialMessage.data}');
    }

    await onNotificationTap(_normalizeMessageData(initialMessage));
  }

  Map<String, dynamic> _normalizeMessageData(RemoteMessage message) {
    final title =
        message.notification?.title ?? message.data['title']?.toString() ?? '';

    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        '';

    return <String, dynamic>{
      ...message.data,
      if (title.isNotEmpty) 'title': title,
      if (body.isNotEmpty) 'body': body,
    };
  }

  int _buildPushNotificationId(RemoteMessage message) {
    final rawId = message.messageId ??
        message.data['notificationId']?.toString() ??
        message.data['eventId']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    int hash = 5381;

    for (final codeUnit in rawId.codeUnits) {
      hash = ((hash << 5) + hash) + codeUnit;
      hash = hash & 0x7fffffff;
    }

    return hash;
  }

  Future<void> dispose() async {
    await _foregroundSub?.cancel();
    await _openedFromBackgroundSub?.cancel();

    _foregroundSub = null;
    _openedFromBackgroundSub = null;
    _initialized = false;
  }
}
