import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/core/config/env.dart';
import 'package:event_app/core/providers/app_providers.dart';
import 'package:event_app/core/services/socket_service.dart';
import 'package:event_app/features/auth/data/repositories/auth_repository.dart';

enum UserRole { admin, user }

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final bool isSessionLocked;
  final bool isRefreshingSession;
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
  final AuthRepository repository;
  final SocketService socketService;

  AuthController(
    this.repository,
    this.socketService,
  ) : super(const AuthState());

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

      socketService.connect(
        baseUrl: Env.baseUrl,
        token: response.accessToken,
      );

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
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void logout() {
    print('CERRANDO SOCKET...');
    socketService.disconnect();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> handleSessionExpired() async {
    if (state.isSessionLocked) return;

    print('🔒 SESIÓN EXPIRADA -> bloqueando app');
    socketService.disconnect();

    state = state.copyWith(
      isSessionLocked: true,
      isAuthenticated: true,
    );
  }

  Future<bool> unlockSessionWithBiometrics({
    required Future<bool> Function() biometricAuth,
  }) async {
    try {
      state = state.copyWith(
        isRefreshingSession: true,
        errorMessage: null,
      );

      final biometricOk = await biometricAuth();

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

      socketService.disconnect();
      socketService.connect(
        baseUrl: Env.baseUrl,
        token: newAccessToken,
      );

      state = state.copyWith(
        token: newAccessToken,
        isSessionLocked: false,
        isRefreshingSession: false,
        isAuthenticated: true,
      );

      return true;
    } catch (e) {
      print('❌ Error renovando sesión: $e');

      state = state.copyWith(
        isRefreshingSession: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );

      return false;
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.read(authRepositoryProvider),
    ref.read(socketServiceProvider),
  );
});
