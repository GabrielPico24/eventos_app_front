import 'package:event_app/core/providers/app_providers.dart';
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
  final dynamic socketService;

  EventsNotifier({
    required this.ref,
    required this.datasource,
    required this.socketService,
  }) : super(const AsyncValue.loading()) {
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    socketService.off('event:created');
    socketService.off('event:updated');
    socketService.off('event:deleted');

    socketService.on('event:created', (data) {
      final current = state.valueOrNull ?? [];
      final event = EventModel.fromJson(Map<String, dynamic>.from(data));

      final exists = current.any((e) => e.id == event.id);
      if (exists) return;

      state = AsyncValue.data([event, ...current]);
    });

    socketService.on('event:updated', (data) {
      final current = state.valueOrNull ?? [];
      final updated = EventModel.fromJson(Map<String, dynamic>.from(data));

      final newList = current.map((event) {
        return event.id == updated.id ? updated : event;
      }).toList();

      state = AsyncValue.data(newList);
    });

    socketService.on('event:deleted', (data) {
      final current = state.valueOrNull ?? [];
      final deletedId = data['id']?.toString() ?? '';

      final newList = current.where((e) => e.id != deletedId).toList();
      state = AsyncValue.data(newList);
    });
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

  Future<void> createEvent({
    required String token,
    required String title,
    required String categoryId,
    required String description,
    required String date,
    required String time,
    required bool isActive,
  }) async {
    await datasource.createEvent(
      token: token,
      title: title,
      categoryId: categoryId,
      description: description,
      date: date,
      time: time,
      isActive: isActive,
    );
  }

  Future<void> updateEvent({
    required String token,
    required String id,
    required String title,
    required String categoryId,
    required String description,
    required String date,
    required String time,
    required bool isActive,
  }) async {
    await datasource.updateEvent(
      token: token,
      id: id,
      title: title,
      categoryId: categoryId,
      description: description,
      date: date,
      time: time,
      isActive: isActive,
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

  @override
  void dispose() {
    socketService.off('event:created');
    socketService.off('event:updated');
    socketService.off('event:deleted');
    super.dispose();
  }
}