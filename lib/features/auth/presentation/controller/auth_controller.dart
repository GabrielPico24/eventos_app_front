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
  final UserRole? role;
  final String? token;
  final String? name;
  final String? email;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.role,
    this.token,
    this.name,
    this.email,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    UserRole? role,
    String? token,
    String? name,
    String? email,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      token: token ?? this.token,
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

      print('LOGIN OK, VOY A CONECTAR SOCKET');
      print('TOKEN LOGIN => ${response.token}');
      print('BASE URL => ${Env.baseUrl}');

      socketService.connect(
        baseUrl: Env.baseUrl,
        token: response.token,
      );

      final role = response.user.role == 'admin'
          ? UserRole.admin
          : UserRole.user;

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        role: role,
        token: response.token,
        name: response.user.name,
        email: response.user.email,
      );
    } catch (e) {
      print('ERROR EN LOGIN => $e');

      state = state.copyWith(
        isLoading: false,
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
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.read(authRepositoryProvider),
    ref.read(socketServiceProvider),
  );
});