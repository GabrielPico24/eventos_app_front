import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/core/config/env.dart';
import 'package:event_app/core/providers/app_providers.dart';
import 'package:event_app/core/services/socket_service.dart';
import 'package:event_app/features/auth/data/repositories/auth_repository.dart';
import 'package:event_app/features/events/presentation/providers/events_provider.dart';
import 'package:event_app/features/categories/presentation/providers/categories_provider.dart';
import 'package:event_app/features/auth/presentation/controller/users_controller.dart';

enum UserRole { admin, user }

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final bool isSessionLocked;
  final bool isRefreshingSession;
  final bool isCheckingStoredSession;
  final UserRole? role;
  final String? token;
  final String? refreshToken;
  final String? name;
  final String? email;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.isSessionLocked = false,
    this.isRefreshingSession = false,
    this.isCheckingStoredSession = true,
    this.role,
    this.token,
    this.refreshToken,
    this.name,
    this.email,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    bool? isSessionLocked,
    bool? isRefreshingSession,
    bool? isCheckingStoredSession,
    UserRole? role,
    String? token,
    String? refreshToken,
    String? name,
    String? email,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isSessionLocked: isSessionLocked ?? this.isSessionLocked,
      isRefreshingSession: isRefreshingSession ?? this.isRefreshingSession,
      isCheckingStoredSession:
          isCheckingStoredSession ?? this.isCheckingStoredSession,
      role: role ?? this.role,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
  );
});

class AuthController extends StateNotifier<AuthState> {
  final Ref ref;
  final AuthRepository repository;
  final SocketService socketService;

  Timer? _sessionTimer;
  bool _sessionExpiredHandled = false;

  AuthController(
    this.ref,
    this.repository,
    this.socketService,
  ) : super(const AuthState()) {
    Future.microtask(() => checkStoredSessionOnAppStart());
  }

  void _cancelSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  DateTime? _getTokenExpiryDate(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final payloadMap = jsonDecode(
        utf8.decode(base64Url.decode(normalized)),
      ) as Map<String, dynamic>;

      final exp = payloadMap['exp'];
      if (exp == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (e) {
      print('❌ Error leyendo exp del token: $e');
      return null;
    }
  }

  void _startSessionTimer(String token) {
    _cancelSessionTimer();

    final expiryDate = _getTokenExpiryDate(token);

    if (expiryDate == null) {
      print('⚠️ No se pudo leer exp del token');
      return;
    }

    final now = DateTime.now();
    final difference = expiryDate.difference(now);

    print('🕒 Token expira en: ${difference.inSeconds} segundos');

    if (difference.isNegative || difference.inSeconds <= 0) {
      Future.microtask(() => handleSessionExpired());
      return;
    }

    _sessionTimer = Timer(difference, () async {
      print('⏰ TOKEN EXPIRADO AUTOMÁTICAMENTE');
      await handleSessionExpired();
    });
  }

  void _updateToken(String newToken) {
    state = state.copyWith(token: newToken);
    _startSessionTimer(newToken);
  }

  Future<void> _persistSession({
    required String accessToken,
    required String refreshToken,
    required String name,
    required String email,
    required String role,
  }) async {
    await ref.read(secureStorageProvider).saveSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
          name: name,
          email: email,
          role: role,
          biometricEnabled: true,
        );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw Exception('Todos los campos son obligatorios');
      }

      final response = await repository.login(
        email: email,
        password: password,
      );

      _sessionExpiredHandled = false;

      final role =
          response.user.role == 'admin' ? UserRole.admin : UserRole.user;

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        role: role,
        token: response.accessToken,
        refreshToken: response.refreshToken,
        name: response.user.name,
        email: response.user.email,
        isSessionLocked: false,
        isRefreshingSession: false,
        isCheckingStoredSession: false,
      );

      await _persistSession(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        name: response.user.name,
        email: response.user.email,
        role: response.user.role,
      );

      _startSessionTimer(response.accessToken);

      socketService.disconnect();
      socketService.connect(
        baseUrl: Env.baseUrl,
        token: response.accessToken,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        isCheckingStoredSession: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> checkStoredSessionOnAppStart() async {
    state = state.copyWith(
      isCheckingStoredSession: true,
      errorMessage: null,
    );

    try {
      final storage = ref.read(secureStorageProvider);

      final hasSession = await storage.hasStoredSession();
      final biometricEnabled = await storage.isBiometricEnabled();

      if (!hasSession || !biometricEnabled) {
        state = state.copyWith(
          isCheckingStoredSession: false,
          isAuthenticated: false,
          isSessionLocked: false,
          token: null,
          refreshToken: null,
          name: null,
          email: null,
          role: null,
        );
        return;
      }

      final refreshToken = await storage.readRefreshToken();
      final name = await storage.readUserName();
      final email = await storage.readUserEmail();
      final roleString = await storage.readUserRole();

      if (refreshToken == null || refreshToken.isEmpty) {
        state = state.copyWith(
          isCheckingStoredSession: false,
          isAuthenticated: false,
          isSessionLocked: false,
          token: null,
          refreshToken: null,
          name: null,
          email: null,
          role: null,
        );
        return;
      }

      final role = roleString == 'admin' ? UserRole.admin : UserRole.user;

      state = state.copyWith(
        isCheckingStoredSession: false,
        isAuthenticated: false,
        isSessionLocked: true,
        refreshToken: refreshToken,
        name: name,
        email: email,
        role: role,
      );
    } catch (e) {
      state = state.copyWith(
        isCheckingStoredSession: false,
        isAuthenticated: false,
        isSessionLocked: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> unlockAppOnLaunchWithBiometrics() async {
    try {
      if (state.isRefreshingSession) return false;

      state = state.copyWith(
        isRefreshingSession: true,
        errorMessage: null,
      );

      final biometricOk =
          await ref.read(biometricServiceProvider).authenticate();

      if (!biometricOk) {
        state = state.copyWith(
          isRefreshingSession: false,
        );
        return false;
      }

      final currentRefreshToken = state.refreshToken;
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        throw Exception('No existe refresh token');
      }

      final newAccessToken = await repository.refreshToken(
        refreshToken: currentRefreshToken,
      );

      print('🟢 NUEVO ACCESS TOKEN RECIBIDO');
      print('🔌 RECONECTANDO SOCKET CON NUEVO TOKEN...');

      _sessionExpiredHandled = false;

      await ref.read(secureStorageProvider).updateAccessToken(newAccessToken);

      state = state.copyWith(
        token: newAccessToken,
        isSessionLocked: false,
        isRefreshingSession: false,
        isAuthenticated: true,
        isCheckingStoredSession: false,
        errorMessage: null,
      );

      _updateToken(newAccessToken);

      socketService.reconnectWithToken(
        baseUrl: Env.baseUrl,
        token: newAccessToken,
      );

      ref.read(eventsProvider.notifier).rebindSocketListeners();
      ref.read(categoriesProvider.notifier).rebindSocketListeners();
      ref.read(usersControllerProvider.notifier).rebindSocketListeners();

      return true;
    } catch (e) {
      print('❌ Error restaurando sesión: $e');

      await ref.read(secureStorageProvider).clearSession();

      state = state.copyWith(
        isRefreshingSession: false,
        isAuthenticated: false,
        isSessionLocked: false,
        isCheckingStoredSession: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );

      return false;
    }
  }

  Future<void> handleSessionExpired() async {
    if (_sessionExpiredHandled) return;
    _sessionExpiredHandled = true;

    print('🔒 SESIÓN EXPIRADA -> bloqueando app');

    _cancelSessionTimer();
    socketService.disconnect();

    state = state.copyWith(
      isSessionLocked: true,
      isAuthenticated: true,
      isRefreshingSession: false,
    );
  }

  Future<bool> unlockSessionWithBiometrics() async {
    try {
      if (state.isRefreshingSession) return false;

      state = state.copyWith(
        isRefreshingSession: true,
        errorMessage: null,
      );

      final biometricOk =
          await ref.read(biometricServiceProvider).authenticate();

      if (!biometricOk) {
        state = state.copyWith(
          isRefreshingSession: false,
        );
        return false;
      }

      final currentRefreshToken = state.refreshToken;
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        throw Exception('No existe refresh token');
      }

      final newAccessToken = await repository.refreshToken(
        refreshToken: currentRefreshToken,
      );

      print('🟢 NUEVO ACCESS TOKEN RECIBIDO');
      print('🔌 RECONECTANDO SOCKET CON NUEVO TOKEN...');

      _sessionExpiredHandled = false;

      await ref.read(secureStorageProvider).updateAccessToken(newAccessToken);

      state = state.copyWith(
        token: newAccessToken,
        isSessionLocked: false,
        isRefreshingSession: false,
        isAuthenticated: true,
        isCheckingStoredSession: false,
        errorMessage: null,
      );

      _updateToken(newAccessToken);

      socketService.reconnectWithToken(
        baseUrl: Env.baseUrl,
        token: newAccessToken,
      );

      ref.read(eventsProvider.notifier).rebindSocketListeners();
      ref.read(categoriesProvider.notifier).rebindSocketListeners();
      ref.read(usersControllerProvider.notifier).rebindSocketListeners();

      return true;
    } catch (e) {
      print('❌ Error renovando sesión: $e');

      await ref.read(secureStorageProvider).clearSession();

      state = state.copyWith(
        isRefreshingSession: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        isAuthenticated: false,
        isSessionLocked: false,
        isCheckingStoredSession: false,
      );

      return false;
    }
  }

  Future<void> logout() async {
    print('🚪 CERRANDO SESIÓN...');
    _cancelSessionTimer();
    _sessionExpiredHandled = false;
    socketService.disconnect();
    await ref.read(secureStorageProvider).clearSession();
    state = const AuthState(
      isCheckingStoredSession: false,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    _cancelSessionTimer();
    super.dispose();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref,
    ref.read(authRepositoryProvider),
    ref.read(socketServiceProvider),
  );
});
