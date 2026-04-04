import 'package:event_app/core/providers/app_providers.dart';
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

  void _initSocketListeners() {
    if (_socketListenersInitialized) return;
    _socketListenersInitialized = true;

    print('🟢 SOCKET: listeners de eventos configurados');

    socketService.off('event:created');
    socketService.off('event:updated');
    socketService.off('event:deleted');

    socketService.on('event:created', (data) {
      try {
        print('🔥 SOCKET RECIBIDO -> event:created');
        print('📦 DATA: $data');

        final current = state.valueOrNull ?? [];
        final event = EventModel.fromJson(Map<String, dynamic>.from(data));

        final exists = current.any((e) => e.id == event.id);
        if (exists) {
          print('⚠️ Evento ya existe, no se agrega duplicado');
          return;
        }

        print('✅ Evento agregado al estado: ${event.id}');
        state = AsyncValue.data([event, ...current]);
      } catch (e, st) {
        print('❌ Error procesando event:created => $e');
        state = AsyncValue.error(e, st);
      }
    });

    socketService.on('event:updated', (data) {
      try {
        print('🟡 SOCKET RECIBIDO -> event:updated');
        print('📦 DATA: $data');

        final current = state.valueOrNull ?? [];
        final updated = EventModel.fromJson(Map<String, dynamic>.from(data));

        final exists = current.any((event) => event.id == updated.id);

        if (!exists) {
          print('⚠️ Evento actualizado no existe en estado, se agrega');
          state = AsyncValue.data([updated, ...current]);
          return;
        }

        final newList = current.map((event) {
          return event.id == updated.id ? updated : event;
        }).toList();

        print('✅ Evento actualizado en estado: ${updated.id}');
        state = AsyncValue.data(newList);
      } catch (e, st) {
        print('❌ Error procesando event:updated => $e');
        state = AsyncValue.error(e, st);
      }
    });

    socketService.on('event:deleted', (data) {
      try {
        print('🔴 SOCKET RECIBIDO -> event:deleted');
        print('📦 DATA: $data');

        final current = state.valueOrNull ?? [];
        final map = Map<String, dynamic>.from(data);

        final deletedId = map['id']?.toString() ?? map['_id']?.toString() ?? '';

        if (deletedId.isEmpty) {
          print('⚠️ No llegó id en event:deleted');
          return;
        }

        final newList = current.where((e) => e.id != deletedId).toList();

        print('🗑️ Evento eliminado del estado: $deletedId');
        state = AsyncValue.data(newList);
      } catch (e, st) {
        print('❌ Error procesando event:deleted => $e');
        state = AsyncValue.error(e, st);
      }
    });
  }

  void rebindSocketListeners() {
    print('🔄 Reenlazando listeners de eventos...');
    _socketListenersInitialized = false;
    _initSocketListeners();
  }

  Future<void> loadEvents({
    required String token,
  }) async {
    try {
      state = const AsyncValue.loading();
      final events = await datasource.getEvents(token: token);
      state = AsyncValue.data(events);
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
      status: status,
      notify24hBefore: notify24hBefore,
      notify1hBefore: notify1hBefore,
      notifyAtTime: notifyAtTime,
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
