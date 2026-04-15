import 'package:event_app/core/providers/app_providers.dart';
import 'package:event_app/core/services/notification_service.dart';
import 'package:event_app/core/services/socket_service.dart';
import 'package:event_app/features/events/data/datasources/events_remote_data_source.dart';
import 'package:event_app/features/events/data/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventsRemoteDataSourceProvider = Provider<EventsRemoteDataSource>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return EventsRemoteDataSource(baseUrl: baseUrl);
});

final eventsProvider =
    StateNotifierProvider<EventsNotifier, AsyncValue<List<EventModel>>>((ref) {
  final datasource = ref.watch(eventsRemoteDataSourceProvider);
  final socketService = ref.watch(socketServiceProvider);

  return EventsNotifier(
    ref: ref,
    datasource: datasource,
    socketService: socketService,
  );
});

class EventsNotifier extends StateNotifier<AsyncValue<List<EventModel>>> {
  final Ref ref;
  final EventsRemoteDataSource datasource;
  final SocketService socketService;

  bool _socketListenersInitialized = false;

  EventsNotifier({
    required this.ref,
    required this.datasource,
    required this.socketService,
  }) : super(const AsyncValue.loading()) {
    _initSocketListeners();
  }

  void _log(String message) {
    print(message);
  }

  void _initSocketListeners() {
    if (_socketListenersInitialized) return;
    _socketListenersInitialized = true;

    _log('🟢 SOCKET: listeners de eventos configurados');

    socketService.off('event:created');
    socketService.off('event:updated');
    socketService.off('event:deleted');

    socketService.on('event:created', (data) {
      try {
        _log('🔥 SOCKET RECIBIDO -> event:created');
        _log('📦 DATA: $data');

        final current = state.valueOrNull ?? [];
        final event = EventModel.fromJson(Map<String, dynamic>.from(data));

        final exists = current.any((e) => e.id == event.id);
        if (exists) {
          _log('⚠️ Evento ya existe, no se agrega duplicado');
          return;
        }

        state = AsyncValue.data([event, ...current]);

        Future.microtask(() => _syncSingleEventFromModel(event));
      } catch (e, st) {
        _log('❌ Error procesando event:created => $e');
        state = AsyncValue.error(e, st);
      }
    });

    socketService.on('event:updated', (data) {
      try {
        _log('🟡 SOCKET RECIBIDO -> event:updated');
        _log('📦 DATA: $data');

        final current = state.valueOrNull ?? [];
        final updated = EventModel.fromJson(Map<String, dynamic>.from(data));

        final exists = current.any((event) => event.id == updated.id);

        if (!exists) {
          state = AsyncValue.data([updated, ...current]);
          Future.microtask(() => _syncSingleEventFromModel(updated));
          return;
        }

        final newList = current.map((event) {
          return event.id == updated.id ? updated : event;
        }).toList();

        state = AsyncValue.data(newList);

        Future.microtask(() => _syncSingleEventFromModel(updated));
      } catch (e, st) {
        _log('❌ Error procesando event:updated => $e');
        state = AsyncValue.error(e, st);
      }
    });

    socketService.on('event:deleted', (data) {
      try {
        _log('🔴 SOCKET RECIBIDO -> event:deleted');
        _log('📦 DATA: $data');

        final current = state.valueOrNull ?? [];
        final map = Map<String, dynamic>.from(data);

        final deletedId = map['id']?.toString() ?? map['_id']?.toString() ?? '';

        if (deletedId.isEmpty) {
          _log('⚠️ No llegó id en event:deleted');
          return;
        }

        final newList = current.where((e) => e.id != deletedId).toList();
        state = AsyncValue.data(newList);

        Future.microtask(
            () => NotificationService.instance.cancelByEventId(deletedId));
      } catch (e, st) {
        _log('❌ Error procesando event:deleted => $e');
        state = AsyncValue.error(e, st);
      }
    });
  }

  void rebindSocketListeners() {
    _log('🔄 Reenlazando listeners de eventos...');
    _socketListenersInitialized = false;
    _initSocketListeners();
  }

  DateTime _parseEventDateTime(String date, String time) {
    final normalizedDate = date.trim();
    final normalizedTime = time.trim().toUpperCase();

    try {
      late int day;
      late int month;
      late int year;

      if (normalizedDate.contains('/')) {
        final dateParts = normalizedDate.split('/');
        if (dateParts.length != 3) {
          throw Exception('Formato de fecha inválido: $date');
        }

        day = int.parse(dateParts[0]);
        month = int.parse(dateParts[1]);
        year = int.parse(dateParts[2]);
      } else if (normalizedDate.contains('-')) {
        final dateParts = normalizedDate.split('-');
        if (dateParts.length != 3) {
          throw Exception('Formato de fecha inválido: $date');
        }

        year = int.parse(dateParts[0]);
        month = int.parse(dateParts[1]);
        day = int.parse(dateParts[2]);
      } else {
        throw Exception('Formato de fecha inválido: $date');
      }

      int hour = 0;
      int minute = 0;

      if (normalizedTime.contains('AM') || normalizedTime.contains('PM')) {
        final clean = normalizedTime.replaceAll(' ', '');
        final isPm = clean.contains('PM');
        final timeOnly = clean.replaceAll('AM', '').replaceAll('PM', '');
        final timeParts = timeOnly.split(':');

        hour = int.parse(timeParts[0]);
        minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

        if (isPm && hour != 12) hour += 12;
        if (!isPm && hour == 12) hour = 0;
      } else {
        final timeParts = normalizedTime.split(':');
        hour = int.parse(timeParts[0]);
        minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
      }

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      _log('❌ Error parseando fecha/hora del evento: $e');
      rethrow;
    }
  }

  LocalNotificationEvent _toLocalNotificationEvent(EventModel event) {
    return LocalNotificationEvent(
      id: event.id,
      title: event.title,
      description: event.description,
      dateTime: _parseEventDateTime(event.date, event.time),
      repeat: event.repeat,
      isActive: event.isActive,
      notify24hBefore: event.notify24hBefore,
      notify1hBefore: event.notify1hBefore,
      notifyAtTime: event.notifyAtTime,
    );
  }

  Future<void> _syncSingleEventFromModel(EventModel event) async {
    try {
      final localEvent = _toLocalNotificationEvent(event);
      print('🔄 Iniciando sync local para evento: ${event.id}');
      await NotificationService.instance.syncSingleEvent(localEvent);
    } catch (e) {
      print('⚠️ Se omitió evento ${event.id} por error de parseo/sync: $e');
    } finally {
      print('✅ Sync local finalizado para evento: ${event.id}');
    }
  }

  Future<void> _resyncNotificationsFromCurrentState() async {
    try {
      final events = state.valueOrNull ?? [];
      final localEvents = <LocalNotificationEvent>[];

      for (final event in events) {
        try {
          localEvents.add(_toLocalNotificationEvent(event));
        } catch (e) {
          _log('⚠️ Se omitió evento ${event.id} por error de parseo: $e');
        }
      }

      await NotificationService.instance.resyncAllEvents(
        events: localEvents,
      );

      _log('🔔 Notificaciones locales resincronizadas');
    } catch (e) {
      _log('❌ Error resincronizando notificaciones: $e');
    }
  }

  Future<void> loadEvents({
    required String token,
  }) async {
    try {
      state = const AsyncValue.loading();
      final events = await datasource.getEvents(token: token);
      state = AsyncValue.data(events);

      await _resyncNotificationsFromCurrentState();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMyEvents({
    required String token,
  }) async {
    try {
      state = const AsyncValue.loading();
      final events = await datasource.getMyEvents(token: token);
      state = AsyncValue.data(events);

      await _resyncNotificationsFromCurrentState();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createEvent({
    required String token,
    required String title,
    required String categoryId,
    required String categoryName,
    required String description,
    required String date,
    required String time,
    required String repeat,
    required bool isActive,
    required List<String> assignedUsers,
    String status = 'upcoming',
    bool notify24hBefore = true,
    bool notify1hBefore = true,
    bool notifyAtTime = true,
  }) async {
    await datasource.createEvent(
      token: token,
      title: title,
      categoryId: categoryId,
      categoryName: categoryName,
      description: description,
      date: date,
      time: time,
      repeat: repeat,
      isActive: isActive,
      assignedUsers: assignedUsers,
      status: status,
      notify24hBefore: notify24hBefore,
      notify1hBefore: notify1hBefore,
      notifyAtTime: notifyAtTime,
    );
  }

  Future<void> updateEvent({
    required String token,
    required String id,
    required String title,
    required String categoryId,
    required String categoryName,
    required String description,
    required String date,
    required String time,
    required String repeat,
    required bool isActive,
    required List<String> assignedUsers,
    String status = 'upcoming',
    bool notify24hBefore = true,
    bool notify1hBefore = true,
    bool notifyAtTime = true,
  }) async {
    await datasource.updateEvent(
      token: token,
      id: id,
      title: title,
      categoryId: categoryId,
      categoryName: categoryName,
      description: description,
      date: date,
      time: time,
      repeat: repeat,
      isActive: isActive,
      assignedUsers: assignedUsers,
      status: status,
      notify24hBefore: notify24hBefore,
      notify1hBefore: notify1hBefore,
      notifyAtTime: notifyAtTime,
    );
  }

  Future<void> deleteEvent({
    required String token,
    required String id,
  }) async {
    await datasource.deleteEvent(
      token: token,
      id: id,
    );
  }

  Future<void> toggleEventStatus({
    required String token,
    required String id,
    required bool isActive,
  }) async {
    await datasource.toggleEventStatus(
      token: token,
      id: id,
      isActive: isActive,
    );
  }

  @override
  void dispose() {
    socketService.off('event:created');
    socketService.off('event:updated');
    socketService.off('event:deleted');
    super.dispose();
  }
}
