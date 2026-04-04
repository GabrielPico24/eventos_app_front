import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const int kMaxOccurrencesDev = 3;
const int kMaxOccurrencesProd = 5;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'event_reminders';
  static const String _channelName = 'Event reminders';
  static const String _channelDescription =
      'Notificaciones locales de recordatorio de eventos';

  int get _maxOccurrences =>
      kDebugMode ? kMaxOccurrencesDev : kMaxOccurrencesProd;

  Future<void> init() async {
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

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
      ),
    );
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ No se pudo obtener timezone nativa: $e');
      }
      tz.setLocalLocation(tz.getLocation('America/Guayaquil'));
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
    }

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final notificationsGranted =
          await android?.requestNotificationsPermission() ?? true;

      final exactAlarmsGranted =
          await android?.requestExactAlarmsPermission() ?? true;

      granted = notificationsGranted && exactAlarmsGranted;
    }

    return granted;
  }

  NotificationDetails _buildDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  int _buildNotificationId(String eventId, String suffix) {
    return '${eventId}_$suffix'.hashCode & 0x7fffffff;
  }

  tz.TZDateTime _toTz(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  bool _hasAnyNotificationEnabled(LocalNotificationEvent event) {
    return event.notify24hBefore || event.notify1hBefore || event.notifyAtTime;
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> scheduleOneTime({
    required String eventId,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required String slotKey,
    String? payload,
  }) async {
    final when = _toTz(scheduledAt);

    if (when.isBefore(tz.TZDateTime.now(tz.local))) {
      if (kDebugMode) {
        print(
            '⏭️ Se omitió notificación pasada -> $eventId | $slotKey | $when');
      }
      return;
    }

    if (kDebugMode) {
      print(
        '🔔 Programando notificación -> eventId: $eventId | slot: $slotKey | when: $when | title: $title',
      );
    }

    await _plugin.zonedSchedule(
      _buildNotificationId(eventId, slotKey),
      title,
      body,
      when,
      _buildDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: null,
    );
  }

  Future<void> scheduleRecurringOccurrences({
    required String eventId,
    required String title,
    required String body,
    required DateTime startDateTime,
    required String repeat,
    required bool notify24hBefore,
    required bool notify1hBefore,
    required bool notifyAtTime,
    String? payload,
    int? maxOccurrences,
  }) async {
    final occurrences = _generateOccurrences(
      startDateTime: startDateTime,
      repeat: repeat,
      maxOccurrences: maxOccurrences ?? _maxOccurrences,
    );

    for (var i = 0; i < occurrences.length; i++) {
      final occurrence = occurrences[i];

      if (notify24hBefore) {
        await scheduleOneTime(
          eventId: eventId,
          title: 'Evento mañana: $title',
          body: body,
          scheduledAt: occurrence.subtract(const Duration(hours: 24)),
          slotKey: 'before24_$i',
          payload: payload,
        );
      }

      if (notify1hBefore) {
        await scheduleOneTime(
          eventId: eventId,
          title: 'Evento en 1 hora: $title',
          body: body,
          scheduledAt: occurrence.subtract(const Duration(hours: 1)),
          slotKey: 'before1_$i',
          payload: payload,
        );
      }

      if (notifyAtTime) {
        await scheduleOneTime(
          eventId: eventId,
          title: title,
          body: body,
          scheduledAt: occurrence,
          slotKey: 'attime_$i',
          payload: payload,
        );
      }
    }
  }

  List<DateTime> _generateOccurrences({
    required DateTime startDateTime,
    required String repeat,
    required int maxOccurrences,
  }) {
    final now = DateTime.now();
    final results = <DateTime>[];
    var current = startDateTime;

    if (repeat == 'never') {
      if (current.isAfter(now)) {
        results.add(current);
      }
      return results;
    }

    while (results.length < maxOccurrences) {
      if (current.isAfter(now)) {
        if (repeat == 'weekdays') {
          final weekday = current.weekday;
          if (weekday >= DateTime.monday && weekday <= DateTime.friday) {
            results.add(current);
          }
        } else if (repeat == 'weekends') {
          final weekday = current.weekday;
          if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
            results.add(current);
          }
        } else {
          results.add(current);
        }
      }

      current = _nextOccurrence(current, repeat);

      if (current.isAfter(now.add(const Duration(days: 3660)))) {
        break;
      }
    }

    return results;
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
    for (int i = 0; i < 60; i++) {
      await _plugin.cancel(_buildNotificationId(eventId, 'before24_$i'));
      await _plugin.cancel(_buildNotificationId(eventId, 'before1_$i'));
      await _plugin.cancel(_buildNotificationId(eventId, 'attime_$i'));
    }
  }

  Future<void> syncSingleEvent(LocalNotificationEvent event) async {
    await cancelByEventId(event.id);

    if (!event.isActive) {
      if (kDebugMode) {
        print('⏭️ Evento inactivo, no se programa: ${event.id}');
      }
      return;
    }

    if (!_hasAnyNotificationEnabled(event)) {
      if (kDebugMode) {
        print('⏭️ Evento sin banderas activas, no se programa: ${event.id}');
      }
      return;
    }

    if (event.dateTime.isBefore(DateTime.now()) && event.repeat == 'never') {
      if (kDebugMode) {
        print('⏭️ Evento pasado sin repetición, no se programa: ${event.id}');
      }
      return;
    }

    if (event.repeat == 'never') {
      if (event.notify24hBefore) {
        await scheduleOneTime(
          eventId: event.id,
          title: 'Evento mañana: ${event.title}',
          body: event.description,
          scheduledAt: event.dateTime.subtract(const Duration(hours: 24)),
          slotKey: 'before24_0',
          payload: event.id,
        );
      }

      if (event.notify1hBefore) {
        await scheduleOneTime(
          eventId: event.id,
          title: 'Evento en 1 hora: ${event.title}',
          body: event.description,
          scheduledAt: event.dateTime.subtract(const Duration(hours: 1)),
          slotKey: 'before1_0',
          payload: event.id,
        );
      }

      if (event.notifyAtTime) {
        await scheduleOneTime(
          eventId: event.id,
          title: event.title,
          body: event.description,
          scheduledAt: event.dateTime,
          slotKey: 'attime_0',
          payload: event.id,
        );
      }

      return;
    }

    await scheduleRecurringOccurrences(
      eventId: event.id,
      title: event.title,
      body: event.description,
      startDateTime: event.dateTime,
      repeat: event.repeat,
      notify24hBefore: event.notify24hBefore,
      notify1hBefore: event.notify1hBefore,
      notifyAtTime: event.notifyAtTime,
      payload: event.id,
    );
  }

  Future<void> resyncAllEvents({
    required List<LocalNotificationEvent> events,
  }) async {
    await cancelAll();

    for (final event in events) {
      await syncSingleEvent(event);
    }
  }
}

class LocalNotificationEvent {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String repeat;
  final bool isActive;
  final bool notify24hBefore;
  final bool notify1hBefore;
  final bool notifyAtTime;

  const LocalNotificationEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.repeat,
    required this.isActive,
    required this.notify24hBefore,
    required this.notify1hBefore,
    required this.notifyAtTime,
  });
}
