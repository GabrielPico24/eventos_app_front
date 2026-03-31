import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/core/providers/app_providers.dart';
import 'package:event_app/features/notifications/data/models/notification_model.dart';

class NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return NotificationsNotifier(socketService: socketService);
});

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final dynamic socketService;

  NotificationsNotifier({
    required this.socketService,
  }) : super(const NotificationsState()) {
    _listenSocket();
  }

  void _listenSocket() {
    socketService.off('notification:new');

    socketService.on('notification:new', (data) {
      final notification =
          NotificationModel.fromJson(Map<String, dynamic>.from(data));

      final updatedList = [notification, ...state.notifications];

      state = state.copyWith(
        notifications: updatedList,
        unreadCount: updatedList.where((n) => !n.read).length,
      );
    });
  }
}