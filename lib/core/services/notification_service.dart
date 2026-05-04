// lib/core/services/notification_service.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const int kMaxOccurrencesDev = 120;
const int kMaxOccurrencesProd = 120;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'event_reminders';
  static const String _channelName = 'Event reminders';
  static const String _channelDescription =
      'Notificaciones locales de recordatorio de eventos';

  static const String _pushChannelId = 'event_push_channel';
  static const String _pushChannelName = 'Eventos';
  static const String _pushChannelDescription =
      'Notificaciones push de la aplicación de eventos';

  bool _initialized = false;

  int get _maxOccurrences =>
      kDebugMode ? kMaxOccurrencesDev : kMaxOccurrencesProd;

  Future<void> init() async {
    if (_initialized) {
      if (kDebugMode) {
        print('ℹ️ NotificationService ya estaba inicializado');
      }
      return;
    }

    _initialized = true;

    tz.initializeTimeZones();
    await _configureLocalTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (kDebugMode) {
          print('🔔 Notificación tocada: ${details.payload}');
        }
      },
    );

    await _createAndroidChannels();

    final permissionsGranted = await requestPermissions();

    if (kDebugMode) {
      print('✅ NotificationService inicializado correctamente');
      print('🌎 Zona horaria local: ${tz.local.name}');
      print('🔐 Permisos locales concedidos: $permissionsGranted');
    }
  }

  Future<void> _createAndroidChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );

    await androidPlugin?.createNotificationChannel(
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
      print('✅ Canal Android creado: $_channelId');
      print('✅ Canal Android creado: $_pushChannelId');
    }
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      if (kDebugMode) {
        print('🌎 Timezone detectada: $timeZoneName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ No se pudo obtener timezone nativa: $e');
      }

      tz.setLocalLocation(tz.getLocation('America/Guayaquil'));

      if (kDebugMode) {
        print('🌎 Timezone fallback usada: America/Guayaquil');
      }
    }
  }

  Future<bool> requestPermissions() async {
    bool granted = true;

    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      final macos = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();

      final iosResult = await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;

      final macosResult = await macos?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;

      granted = iosResult || macosResult;

      if (kDebugMode) {
        print('🔔 Permiso notificaciones iOS/macOS: $granted');
      }
    }

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final notificationsGranted =
          await android?.requestNotificationsPermission() ?? true;

      final exactAlarmsGranted = await _requestExactAlarmPermission();

      granted = notificationsGranted && exactAlarmsGranted;

      if (kDebugMode) {
        print('🔔 Permiso notificaciones Android: $notificationsGranted');
        print('⏰ Permiso alarmas exactas Android: $exactAlarmsGranted');
      }
    }

    return granted;
  }

  Future<bool> _requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) return true;

    try {
      final bool canSchedule =
          await android.canScheduleExactNotifications() ?? false;

      if (canSchedule) {
        return true;
      }

      await android.requestExactAlarmsPermission();

      final bool canScheduleAfterRequest =
          await android.canScheduleExactNotifications() ?? false;

      return canScheduleAfterRequest;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ No se pudo solicitar alarmas exactas: $e');
      }

      return false;
    }
  }

  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) return true;

    try {
      final bool canSchedule =
          await android.canScheduleExactNotifications() ?? false;

      return canSchedule;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ No se pudo consultar alarmas exactas: $e');
      }

      return false;
    }
  }

  Future<AndroidScheduleMode> _getAndroidScheduleMode() async {
    if (!Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    final canExact = await canScheduleExactAlarms();

    if (canExact) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    if (kDebugMode) {
      print(
        '⚠️ Android no permite alarmas exactas. '
        'Se usará inexactAllowWhileIdle para evitar que la app falle.',
      );
    }

    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  NotificationDetails _buildReminderDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
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
    );
  }

  NotificationDetails _buildPushDetails() {
    return const NotificationDetails(
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
    );
  }

  int _buildNotificationId(String eventId, String suffix) {
    final value = '${eventId}_$suffix';
    int hash = 5381;

    for (final codeUnit in value.codeUnits) {
      hash = ((hash << 5) + hash) + codeUnit;
      hash = hash & 0x7fffffff;
    }

    return hash;
  }

  int _buildInstantNotificationId(String value) {
    int hash = 5381;

    for (final codeUnit in value.codeUnits) {
      hash = ((hash << 5) + hash) + codeUnit;
      hash = hash & 0x7fffffff;
    }

    return hash;
  }

  tz.TZDateTime _toTz(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  bool _hasAnyNotificationEnabled(LocalNotificationEvent event) {
    return event.notifyAtTime;
  }

  bool _shouldScheduleForThisDevice(LocalNotificationEvent event) {
    if (event.currentUserRole.trim().toLowerCase() == 'admin') {
      return false;
    }

    if (event.currentUserId.trim().isEmpty) {
      return true;
    }

    final currentUserId = event.currentUserId.trim();

    final assignedIds = event.assignedUserIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();

    if (assignedIds.isNotEmpty) {
      return assignedIds.contains(currentUserId);
    }

    if (event.createdById.trim().isNotEmpty) {
      return event.createdById.trim() == currentUserId;
    }

    return true;
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();

    if (kDebugMode) {
      print('🧹 Todas las notificaciones locales fueron canceladas');
    }
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final id = _buildInstantNotificationId(
      '${DateTime.now().millisecondsSinceEpoch}_${title}_$body',
    );

    await _plugin.show(
      id,
      title,
      body,
      _buildPushDetails(),
      payload: payload,
    );

    if (kDebugMode) {
      print('🔔 Notificación instantánea mostrada -> $title');
    }
  }

  Future<bool> scheduleOneTime({
    required String eventId,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required String slotKey,
    String? payload,
  }) async {
    final when = _toTz(scheduledAt);
    final now = tz.TZDateTime.now(tz.local);

    if (when.isBefore(now.add(const Duration(seconds: 10)))) {
      if (kDebugMode) {
        print(
          '⏭️ Se omitió notificación pasada/cercana -> '
          'eventId: $eventId | slot: $slotKey | when: ${_formatDateTime(scheduledAt)}',
        );
      }
      return false;
    }

    final scheduleMode = await _getAndroidScheduleMode();

    if (kDebugMode) {
      print(
        '🔔 Programando notificación -> '
        'eventId: $eventId | slot: $slotKey | '
        'fecha: ${_formatDateTime(scheduledAt)} | '
        'title: $title | mode: $scheduleMode',
      );
    }

    await _plugin.zonedSchedule(
      _buildNotificationId(eventId, slotKey),
      title,
      body,
      when,
      _buildReminderDetails(),
      androidScheduleMode: scheduleMode,
      payload: payload,
      matchDateTimeComponents: null,
    );

    return true;
  }

  Future<void> scheduleRecurringOccurrences({
    required String eventId,
    required String title,
    required String body,
    required DateTime startDateTime,
    required String repeat,
    required String repeatEndDate,
    required bool notify24hBefore,
    required bool notify1hBefore,
    required bool notifyAtTime,
    String? payload,
    int? maxOccurrences,
  }) async {
    final normalizedRepeat = repeat.trim().toLowerCase();

    if (!notifyAtTime) {
      if (kDebugMode) {
        print(
          '⏭️ notifyAtTime está desactivado, no se programa ninguna ocurrencia: $eventId',
        );
      }
      return;
    }

    final occurrences = _generateOccurrences(
      startDateTime: startDateTime,
      repeat: normalizedRepeat,
      repeatEndDate: repeatEndDate,
      maxOccurrences: maxOccurrences ?? _maxOccurrences,
    );

    if (kDebugMode) {
      print('====================================================');
      print('📌 EVENTO A PROGRAMAR SOLO EN HORA EXACTA');
      print('🆔 eventId: $eventId');
      print('📝 title: $title');
      print('📅 inicio: ${_formatDateTime(startDateTime)}');
      print('🔁 repeat: $normalizedRepeat');
      print('🏁 repeatEndDate: ${repeatEndDate.trim()}');
      print('🚫 notify24hBefore ignorado');
      print('🚫 notify1hBefore ignorado');
      print('✅ notifyAtTime activo');
      print('🔢 Total ocurrencias exactas generadas: ${occurrences.length}');

      if (occurrences.isEmpty) {
        print('⚠️ No se generaron ocurrencias futuras para este evento');
      } else {
        for (var i = 0; i < occurrences.length; i++) {
          print(
            '📍 Hora exacta ${i + 1}/${occurrences.length}: '
            '${_formatDateTime(occurrences[i])}',
          );
        }
      }

      print('====================================================');
    }

    int scheduledCount = 0;

    for (var i = 0; i < occurrences.length; i++) {
      final occurrence = occurrences[i];

      final wasScheduled = await scheduleOneTime(
        eventId: eventId,
        title: title,
        body: body.isNotEmpty ? body : 'Tienes un evento programado',
        scheduledAt: occurrence,
        slotKey: 'attime_$i',
        payload: payload,
      );

      if (wasScheduled) {
        scheduledCount++;
      }
    }

    if (kDebugMode) {
      print(
        '✅ Programación finalizada para $eventId -> '
        'ocurrencias exactas: ${occurrences.length} | '
        'notificaciones exactas programadas: $scheduledCount',
      );
    }
  }

  List<DateTime> _generateOccurrences({
    required DateTime startDateTime,
    required String repeat,
    required String repeatEndDate,
    required int maxOccurrences,
  }) {
    final now = DateTime.now();
    final safeNow = now.add(const Duration(seconds: 10));
    final results = <DateTime>[];

    final normalizedRepeat = repeat.trim().toLowerCase();

    var current = DateTime(
      startDateTime.year,
      startDateTime.month,
      startDateTime.day,
      startDateTime.hour,
      startDateTime.minute,
    );

    if (normalizedRepeat == 'never') {
      if (current.isAfter(safeNow)) {
        results.add(current);
      }

      if (kDebugMode) {
        print(
          '🔁 Repetición never -> ocurrencias generadas: ${results.length}',
        );
      }

      return results;
    }

    final endDate = _parseRepeatEndDate(
      repeatEndDate: repeatEndDate,
      fallbackDateTime: startDateTime,
    );

    if (endDate == null) {
      if (kDebugMode) {
        print(
          '⏭️ Repetición sin fecha fin válida. '
          'repeatEndDate: $repeatEndDate',
        );
      }
      return results;
    }

    if (endDate.isBefore(current)) {
      if (kDebugMode) {
        print(
          '⏭️ Fecha fin menor a fecha inicio. '
          'inicio: ${_formatDateTime(current)} | fin: ${_formatDateTime(endDate)}',
        );
      }
      return results;
    }

    if (kDebugMode) {
      print(
        '🔁 Generando ocurrencias -> '
        'repeat: $normalizedRepeat | '
        'inicio: ${_formatDateTime(current)} | '
        'fin: ${_formatDateTime(endDate)} | '
        'max: $maxOccurrences',
      );
    }

    while (!current.isAfter(endDate) && results.length < maxOccurrences) {
      if (current.isAfter(safeNow)) {
        if (_isValidOccurrenceForRepeat(current, normalizedRepeat)) {
          results.add(current);

          if (kDebugMode) {
            print('✅ Ocurrencia generada: ${_formatDateTime(current)}');
          }
        } else {
          if (kDebugMode) {
            print(
              '⏭️ Ocurrencia no aplica para $normalizedRepeat: '
              '${_formatDateTime(current)}',
            );
          }
        }
      } else {
        if (kDebugMode) {
          print(
            '⏭️ Ocurrencia pasada/cercana omitida: '
            '${_formatDateTime(current)}',
          );
        }
      }

      current = _nextOccurrence(current, normalizedRepeat);

      if (current.isAfter(now.add(const Duration(days: 3660)))) {
        if (kDebugMode) {
          print('⚠️ Se detuvo la generación por seguridad de fecha muy lejana');
        }
        break;
      }
    }

    if (results.length >= maxOccurrences && kDebugMode) {
      print(
        '⚠️ Se alcanzó el límite máximo de ocurrencias: $maxOccurrences',
      );
    }

    return results;
  }

  DateTime? _parseRepeatEndDate({
    required String repeatEndDate,
    required DateTime fallbackDateTime,
  }) {
    final cleanValue = repeatEndDate.trim();

    if (cleanValue.isEmpty) {
      return null;
    }

    try {
      if (cleanValue.contains('/')) {
        final parts = cleanValue.split('/');

        if (parts.length != 3) {
          return null;
        }

        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        return DateTime(year, month, day, 23, 59, 59);
      }

      if (cleanValue.contains('-')) {
        final parsed = DateTime.tryParse(cleanValue);

        if (parsed == null) {
          return null;
        }

        return DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  bool _isValidOccurrenceForRepeat(DateTime date, String repeat) {
    switch (repeat) {
      case 'hourly':
        return true;

      case 'daily':
        return true;

      case 'weekdays':
        return date.weekday >= DateTime.monday &&
            date.weekday <= DateTime.friday;

      case 'weekends':
        return date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;

      case 'weekly':
        return true;

      case 'biweekly':
        return true;

      case 'monthly':
        return true;

      case 'quarterly':
        return true;

      case 'semiannual':
        return true;

      case 'yearly':
        return true;

      default:
        return false;
    }
  }

  DateTime _nextOccurrence(DateTime current, String repeat) {
    switch (repeat) {
      case 'hourly':
        return current.add(const Duration(hours: 1));

      case 'daily':
        return current.add(const Duration(days: 1));

      case 'weekdays':
      case 'weekends':
        return current.add(const Duration(days: 1));

      case 'weekly':
        return current.add(const Duration(days: 7));

      case 'biweekly':
        return current.add(const Duration(days: 14));

      case 'monthly':
        return _addMonths(current, 1);

      case 'quarterly':
        return _addMonths(current, 3);

      case 'semiannual':
        return _addMonths(current, 6);

      case 'yearly':
        return _addMonths(current, 12);

      default:
        return current.add(const Duration(days: 1));
    }
  }

  DateTime _addMonths(DateTime date, int monthsToAdd) {
    final newYear = date.year + ((date.month - 1 + monthsToAdd) ~/ 12);
    final newMonth = ((date.month - 1 + monthsToAdd) % 12) + 1;

    final lastDay = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = date.day > lastDay ? lastDay : date.day;

    return DateTime(
      newYear,
      newMonth,
      newDay,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  Future<void> cancelByEventId(String eventId) async {
    for (int i = 0; i < _maxOccurrences; i++) {
      await _plugin.cancel(_buildNotificationId(eventId, 'before24_$i'));
      await _plugin.cancel(_buildNotificationId(eventId, 'before1_$i'));
      await _plugin.cancel(_buildNotificationId(eventId, 'attime_$i'));
    }

    if (kDebugMode) {
      print('🧹 Notificaciones canceladas para eventId: $eventId');
    }
  }

  Future<void> syncSingleEvent(LocalNotificationEvent event) async {
    await cancelByEventId(event.id);

    if (kDebugMode) {
      print('====================================================');
      print('🔄 SINCRONIZANDO EVENTO LOCAL');
      print('🆔 id: ${event.id}');
      print('📝 title: ${event.title}');
      print('📅 dateTime: ${_formatDateTime(event.dateTime)}');
      print('🔁 repeat: ${event.repeat}');
      print('🏁 repeatEndDate: ${event.repeatEndDate}');
      print('✅ isActive: ${event.isActive}');
      print('🔔 notify24hBefore: ${event.notify24hBefore}');
      print('🔔 notify1hBefore: ${event.notify1hBefore}');
      print('🔔 notifyAtTime: ${event.notifyAtTime}');
      print('👤 currentUserId: ${event.currentUserId}');
      print('👤 currentUserRole: ${event.currentUserRole}');
      print('👤 createdById: ${event.createdById}');
      print('👥 assignedUserIds: ${event.assignedUserIds}');
      print('====================================================');
    }

    if (!event.isActive) {
      if (kDebugMode) {
        print('⏭️ Evento inactivo, no se programa: ${event.id}');
      }
      return;
    }

    if (!_shouldScheduleForThisDevice(event)) {
      if (kDebugMode) {
        print(
          '⏭️ Este dispositivo no debe programar este evento: '
          '${event.id} | currentUserId: ${event.currentUserId}',
        );
      }
      return;
    }

    if (!_hasAnyNotificationEnabled(event)) {
      if (kDebugMode) {
        print(
          '⏭️ Evento sin notificaciones activas, no se programa: ${event.id}',
        );
      }
      return;
    }

    if (event.dateTime.isBefore(DateTime.now()) && event.repeat == 'never') {
      if (kDebugMode) {
        print('⏭️ Evento pasado sin repetición, no se programa: ${event.id}');
      }
      return;
    }

    await scheduleRecurringOccurrences(
      eventId: event.id,
      title: event.title,
      body: event.description.isNotEmpty
          ? event.description
          : 'Tienes un evento programado',
      startDateTime: event.dateTime,
      repeat: event.repeat,
      repeatEndDate: event.repeatEndDate,
      notify24hBefore: event.notify24hBefore,
      notify1hBefore: event.notify1hBefore,
      notifyAtTime: event.notifyAtTime,
      payload: event.id,
    );
  }

  Future<void> resyncAllEvents({
    required List<LocalNotificationEvent> events,
  }) async {
    if (kDebugMode) {
      print('🔄 Resincronizando ${events.length} eventos locales...');
      print('ℹ️ No se usará cancelAll() para evitar perder alarmas cercanas.');
    }

    for (final event in events) {
      await syncSingleEvent(event);
    }

    if (kDebugMode) {
      print('✅ Resincronización completa de eventos locales');
    }
  }
}

class LocalNotificationEvent {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String repeat;
  final String repeatEndDate;
  final bool isActive;
  final bool notify24hBefore;
  final bool notify1hBefore;
  final bool notifyAtTime;

  final String currentUserId;
  final String currentUserRole;
  final String createdById;
  final List<String> assignedUserIds;

  const LocalNotificationEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.repeat,
    required this.repeatEndDate,
    required this.isActive,
    required this.notify24hBefore,
    required this.notify1hBefore,
    required this.notifyAtTime,
    this.currentUserId = '',
    this.currentUserRole = '',
    this.createdById = '',
    this.assignedUserIds = const [],
  });
}
