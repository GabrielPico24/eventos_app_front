import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/core/providers/app_providers.dart';
import 'package:event_app/core/services/socket_service.dart';
import 'package:event_app/features/admin/data/models/admin_dashboard_stats.dart';
import 'package:event_app/features/admin/presentation/providers/admin_dashboard_state.dart';

final adminDashboardControllerProvider =
    StateNotifierProvider<AdminDashboardController, AdminDashboardState>((ref) {
  final socketService = ref.watch(socketServiceProvider);

  final controller = AdminDashboardController(
    socketService: socketService,
  );

  ref.onDispose(() {
    controller.disposeController();
  });

  return controller;
});

class AdminDashboardController extends StateNotifier<AdminDashboardState> {
  final SocketService socketService;

  bool _disposed = false;
  bool _dashboardListenerAttached = false;
  bool _socketLifecycleAttached = false;

  AdminDashboardController({
    required this.socketService,
  }) : super(const AdminDashboardState(isLoading: true)) {
    _init();
  }

  void _init() {
    _attachSocketLifecycleListeners();
    _attachDashboardStatsListener();

    Future.delayed(const Duration(milliseconds: 300), () {
      requestDashboardStats();
    });
  }

  void requestDashboardStats() {
    if (_disposed) return;

    final socket = socketService.socket;

    if (socket == null) {
      print('⚠️ Dashboard: socket null, no se puede pedir estadísticas');

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Socket no disponible',
      );

      return;
    }

    if (socket.connected != true) {
      print('⚠️ Dashboard: socket aún no conectado');

      state = state.copyWith(
        isLoading: true,
        clearError: true,
      );

      return;
    }

    print('📤 Dashboard: solicitando estadísticas por socket...');

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    socket.emit('dashboard:get-stats');
  }

  void _attachSocketLifecycleListeners() {
    if (_disposed) return;
    if (_socketLifecycleAttached) return;

    final socket = socketService.socket;

    if (socket == null) {
      print('⚠️ Dashboard: socket null al enlazar ciclo de vida');
      return;
    }

    socket.on('connect', (_) {
      if (_disposed) return;

      print('📊 Dashboard: socket conectado, solicitando estadísticas...');

      _dashboardListenerAttached = false;
      _attachDashboardStatsListener();
      requestDashboardStats();
    });

    socket.on('reconnect', (_) {
      if (_disposed) return;

      print('📊 Dashboard: socket reconectado, solicitando estadísticas...');

      _dashboardListenerAttached = false;
      _attachDashboardStatsListener();
      requestDashboardStats();
    });

    _socketLifecycleAttached = true;
  }

  void _attachDashboardStatsListener() {
    if (_disposed) return;
    if (_dashboardListenerAttached) return;

    final socket = socketService.socket;

    if (socket == null) {
      print('⚠️ Dashboard: socket null, no se pudo enlazar listener');
      return;
    }

    socket.off('dashboard:stats-updated');
    socket.off('dashboard:stats-error');

    socket.on('dashboard:stats-updated', (data) {
      if (_disposed) return;

      print('📥 dashboard:stats-updated => $data');

      try {
        Map<String, dynamic> mapData;

        if (data is Map<String, dynamic>) {
          mapData = data;
        } else if (data is Map) {
          mapData = Map<String, dynamic>.from(data);
        } else {
          throw Exception('Formato inválido recibido por socket');
        }

        final stats = AdminDashboardStats.fromJson(mapData);

        state = state.copyWith(
          isLoading: false,
          stats: stats,
          clearError: true,
        );
      } catch (e) {
        print('❌ Error parseando dashboard:stats-updated => $e');

        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Error al procesar estadísticas',
        );
      }
    });

    socket.on('dashboard:stats-error', (data) {
      if (_disposed) return;

      print('❌ dashboard:stats-error => $data');

      String message = 'Error al obtener estadísticas del dashboard';

      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: message,
      );
    });

    print('✅ Dashboard listener socket enlazado');

    _dashboardListenerAttached = true;
  }

  void rebindSocketListeners() {
    if (_disposed) return;

    print('🔄 Dashboard: reenlazando listeners socket...');

    _dashboardListenerAttached = false;
    _socketLifecycleAttached = false;

    _attachSocketLifecycleListeners();
    _attachDashboardStatsListener();
    requestDashboardStats();
  }

  void disposeController() {
    _disposed = true;

    final socket = socketService.socket;

    socket?.off('dashboard:stats-updated');
    socket?.off('dashboard:stats-error');

    _dashboardListenerAttached = false;
    _socketLifecycleAttached = false;
  }
}
