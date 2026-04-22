import 'package:event_app/core/providers/app_providers.dart';
import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:event_app/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:event_app/features/notifications/data/models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;

  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }
}

final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return NotificationsRemoteDataSource(baseUrl: baseUrl);
});

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  final remote = ref.watch(notificationsRemoteDataSourceProvider);

  return NotificationsNotifier(
    ref: ref,
    socketService: socketService,
    remote: remote,
  );
});

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final Ref ref;
  final dynamic socketService;
  final NotificationsRemoteDataSource remote;

  NotificationsNotifier({
    required this.ref,
    required this.socketService,
    required this.remote,
  }) : super(const NotificationsState()) {
    _listenSocket();
  }

  void _listenSocket() {
    socketService.off('notification:new');
    socketService.off('notification:history-updated');

    socketService.on('notification:new', (data) {
      final notification =
          NotificationModel.fromJson(Map<String, dynamic>.from(data));

      final alreadyExists =
          state.notifications.any((n) => n.id == notification.id);

      if (alreadyExists) return;

      final updatedList = [notification, ...state.notifications];

      state = state.copyWith(
        notifications: updatedList,
        unreadCount: updatedList.where((n) => !n.read).length,
      );
    });

    socketService.on('notification:history-updated', (data) {
      final notification =
          NotificationModel.fromJson(Map<String, dynamic>.from(data));

      final alreadyExists =
          state.notifications.any((n) => n.id == notification.id);

      if (alreadyExists) return;

      final updatedList = [notification, ...state.notifications];

      state = state.copyWith(
        notifications: updatedList,
        unreadCount: updatedList.where((n) => !n.read).length,
      );
    });
  }

  Future<void> loadNotifications() async {
    try {
      final token = ref.read(authControllerProvider).token ?? '';
      if (token.isEmpty) throw Exception('No existe token de sesión');

      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
      );

      final notifications = await remote.getNotifications(token: token);

      state = state.copyWith(
        isLoading: false,
        notifications: notifications,
        unreadCount: notifications.where((n) => !n.read).length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> sendNotification({
    required String title,
    required String message,
    required String category,
    required bool sendToAll,
    required List<String> userIds,
  }) async {
    try {
      final token = ref.read(authControllerProvider).token ?? '';
      if (token.isEmpty) throw Exception('No existe token de sesión');

      state = state.copyWith(
        isSending: true,
        errorMessage: null,
      );

      await remote.sendNotification(
        token: token,
        title: title,
        message: message,
        category: category,
        sendToAll: sendToAll,
        userIds: userIds,
      );

      state = state.copyWith(
        isSending: false,
      );

      await loadNotifications();
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  void rebindSocketListeners() {
    _listenSocket();
  }

  @override
  void dispose() {
    socketService.off('notification:new');
    socketService.off('notification:history-updated');
    super.dispose();
  }
}
