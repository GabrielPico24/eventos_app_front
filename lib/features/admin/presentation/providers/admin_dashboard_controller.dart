import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/core/providers/app_providers.dart';
import 'package:event_app/core/services/socket_service.dart';
import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:event_app/features/admin/data/datasources/admin_dashboard_remote_data_source.dart';
import 'package:event_app/features/admin/data/models/admin_dashboard_stats.dart';
import 'package:event_app/features/admin/presentation/providers/admin_dashboard_state.dart';

final adminDashboardRemoteDataSourceProvider =
    Provider<AdminDashboardRemoteDataSource>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return AdminDashboardRemoteDataSource(baseUrl: baseUrl);
});

final adminDashboardControllerProvider =
    StateNotifierProvider<AdminDashboardController, AdminDashboardState>((ref) {
  final remote = ref.watch(adminDashboardRemoteDataSourceProvider);
  final socketService = ref.watch(socketServiceProvider);

  final controller = AdminDashboardController(
    ref: ref,
    remote: remote,
    socketService: socketService,
  );

  ref.onDispose(() {
    controller.disposeController();
  });

  return controller;
});

class AdminDashboardController extends StateNotifier<AdminDashboardState> {
  final Ref ref;
  final AdminDashboardRemoteDataSource remote;
  final SocketService socketService;

  bool _dashboardListenerAttached = false;
  bool _socketLifecycleAttached = false;

  AdminDashboardController({
    required this.ref,
    required this.remote,
    required this.socketService,
  }) : super(const AdminDashboardState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    await loadStats();
    _attachSocketLifecycleListeners();
    _attachDashboardStatsListener();
  }

  Future<void> loadStats() async {
    try {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
      );

      final authState = ref.read(authControllerProvider);
      final token = authState.token;

      if (token == null || token.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Token no disponible',
        );
        return;
      }

      final stats = await remote.getDashboardStats(token: token);

      state = state.copyWith(
        isLoading: false,
        stats: stats,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void _attachSocketLifecycleListeners() {
    if (_socketLifecycleAttached) return;

    final socket = socketService.socket;
    if (socket == null) return;

    socket.off('connect');
    socket.on('connect', (_) {
      print('📊 Dashboard: socket conectado, reenlazando listener...');
      _dashboardListenerAttached = false;
      _attachDashboardStatsListener();
      loadStats();
    });

    _socketLifecycleAttached = true;
  }

  void _attachDashboardStatsListener() {
    if (_dashboardListenerAttached) return;

    final socket = socketService.socket;
    if (socket == null) return;

    socket.off('dashboard:stats-updated');
    socket.on('dashboard:stats-updated', (data) {
      print('📥 dashboard:stats-updated => $data');

      try {
        if (data is Map<String, dynamic>) {
          final stats = AdminDashboardStats.fromJson(data);
          state = state.copyWith(
            stats: stats,
            isLoading: false,
            clearError: true,
          );
        } else if (data is Map) {
          final stats =
              AdminDashboardStats.fromJson(Map<String, dynamic>.from(data));
          state = state.copyWith(
            stats: stats,
            isLoading: false,
            clearError: true,
          );
        } else {
          loadStats();
        }
      } catch (e) {
        print('❌ Error parseando dashboard:stats-updated => $e');
        loadStats();
      }
    });

    _dashboardListenerAttached = true;
  }

  void rebindSocketListeners() {
    print('🔄 Reenlazando dashboard socket listeners...');
    _dashboardListenerAttached = false;
    _socketLifecycleAttached = false;
    _attachSocketLifecycleListeners();
    _attachDashboardStatsListener();
  }

  void disposeController() {
    final socket = socketService.socket;
    socket?.off('dashboard:stats-updated');
    socket?.off('connect');
  }
}
