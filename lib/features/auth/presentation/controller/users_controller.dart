import 'dart:async';

import 'package:event_app/core/config/env.dart';
import 'package:event_app/core/providers/app_providers.dart';
import 'package:event_app/core/services/socket_service.dart';
import 'package:event_app/features/auth/data/datasource/users_remote_datasource.dart';
import 'package:event_app/features/auth/data/repositories/users_repository.dart';
import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:event_app/features/auth/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersState {
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? errorMessage;
  final List<UserModel> users;

  const UsersState({
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorMessage,
    this.users = const [],
  });

  UsersState copyWith({
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? errorMessage,
    List<UserModel>? users,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage,
      users: users ?? this.users,
    );
  }
}

final usersRemoteDataSourceProvider = Provider<UsersRemoteDataSource>((ref) {
  return UsersRemoteDataSource(
    baseUrl: Env.baseUrl,
  );
});

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(
    remoteDataSource: ref.read(usersRemoteDataSourceProvider),
  );
});

class UsersController extends StateNotifier<UsersState> {
  final Ref ref;
  final UsersRepository repository;
  final SocketService socketService;

  bool _socketListenersInitialized = false;

  UsersController(
    this.ref,
    this.repository,
    this.socketService,
  ) : super(const UsersState()) {
    _initSocketListeners();
  }

  void _initSocketListeners() {
    if (_socketListenersInitialized) return;
    _socketListenersInitialized = true;

    socketService.off('user:created');
    socketService.off('user:updated');
    socketService.off('user:deleted');

    socketService.on('user:created', (data) {
      try {
        print('📥 socket user:created => $data');
        final user = UserModel.fromJson(Map<String, dynamic>.from(data));
        _onUserCreated(user);
      } catch (e) {
        print('❌ error en user:created => $e');
      }
    });

    socketService.on('user:updated', (data) {
      try {
        print('📥 socket user:updated => $data');
        final user = UserModel.fromJson(Map<String, dynamic>.from(data));
        _onUserUpdated(user);
      } catch (e) {
        print('❌ error en user:updated => $e');
      }
    });

    socketService.on('user:deleted', (data) {
      try {
        print('📥 socket user:deleted => $data');

        final map = Map<String, dynamic>.from(data);
        final id = map['id']?.toString() ?? map['_id']?.toString();

        if (id != null && id.isNotEmpty) {
          _onUserDeleted(id);
        }
      } catch (e) {
        print('❌ error en user:deleted => $e');
      }
    });

    print('✅ Listeners de usuarios registrados');
  }

  void rebindSocketListeners() {
    print('🔄 Reenlazando listeners de usuarios...');
    _socketListenersInitialized = false;
    _initSocketListeners();
  }

  Future<void> loadUsers() async {
    try {
      final authState = ref.read(authControllerProvider);
      final token = authState.token;

      if (token == null || token.isEmpty) {
        throw Exception('No existe token de sesión');
      }

      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
      );

      final users = await repository.getUsers(token: token);

      final currentUserEmail = (authState.email ?? '').trim().toLowerCase();

      final filteredUsers = users.where((user) {
        final userEmail = user.email.trim().toLowerCase();
        return userEmail != currentUserEmail;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        users: filteredUsers,
      );
    } catch (e) {
      final message = e.toString();

      if (message.contains('401|')) {
        print('🔒 TOKEN EXPIRADO detectado en UsersController.loadUsers');
        await ref.read(authControllerProvider.notifier).handleSessionExpired();
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> createUser({
  required String name,
  required String email,
  required String password,
  required String role,
  required bool isActive,
}) async {
  try {
    final token = ref.read(authControllerProvider).token;

    if (token == null || token.isEmpty) {
      throw Exception('No existe token de sesión');
    }

    state = state.copyWith(
      isCreating: true,
      errorMessage: null,
    );

    final createdUser = await repository.createUser(
      token: token,
      name: name,
      email: email,
      password: password,
      role: role,
      isActive: isActive,
    );

    _onUserCreated(createdUser);

    state = state.copyWith(
      isCreating: false,
    );
  } catch (e) {
    final message = e.toString();

    if (message.contains('401|')) {
      print('🔒 TOKEN EXPIRADO detectado en UsersController.createUser');
      await ref.read(authControllerProvider.notifier).handleSessionExpired();
    }

    state = state.copyWith(
      isCreating: false,
      errorMessage: e.toString().replaceFirst('Exception: ', ''),
    );
    rethrow;
  }
}

  Future<void> updateUser({
    required String id,
    required String name,
    required String email,
    required String password,
    required String role,
    required bool isActive,
  }) async {
    try {
      final token = ref.read(authControllerProvider).token;

      if (token == null || token.isEmpty) {
        throw Exception('No existe token de sesión');
      }

      state = state.copyWith(
        isUpdating: true,
        errorMessage: null,
      );

      await repository.updateUser(
        token: token,
        id: id,
        name: name,
        email: email,
        password: password,
        role: role,
        isActive: isActive,
      );

      state = state.copyWith(
        isUpdating: false,
      );
    } catch (e) {
      final message = e.toString();

      if (message.contains('401|')) {
        print('🔒 TOKEN EXPIRADO detectado en UsersController.updateUser');
        await ref.read(authControllerProvider.notifier).handleSessionExpired();
      }

      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> deleteUser({
    required String id,
  }) async {
    try {
      final authState = ref.read(authControllerProvider);
      final token = authState.token;
      final currentUserEmail = (authState.email ?? '').trim().toLowerCase();

      if (token == null || token.isEmpty) {
        throw Exception('No existe token de sesión');
      }

      final userToDelete = state.users.cast<UserModel?>().firstWhere(
        (user) => user?.id == id,
        orElse: () => null,
      );

      if (userToDelete != null &&
          userToDelete.email.trim().toLowerCase() == currentUserEmail) {
        throw Exception('No puedes eliminar tu propio usuario');
      }

      state = state.copyWith(
        isDeleting: true,
        errorMessage: null,
      );

      await repository.deleteUser(
        token: token,
        id: id,
      );

      state = state.copyWith(
        isDeleting: false,
      );
    } catch (e) {
      final message = e.toString();

      if (message.contains('401|')) {
        print('🔒 TOKEN EXPIRADO detectado en UsersController.deleteUser');
        await ref.read(authControllerProvider.notifier).handleSessionExpired();
      }

      state = state.copyWith(
        isDeleting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  void _onUserCreated(UserModel user) {
    final authState = ref.read(authControllerProvider);
    final currentUserEmail = (authState.email ?? '').trim().toLowerCase();
    final userEmail = user.email.trim().toLowerCase();

    if (userEmail == currentUserEmail) return;

    final alreadyExists = state.users.any((u) => u.id == user.id);
    if (alreadyExists) return;

    state = state.copyWith(
      users: [user, ...state.users],
    );
  }

  void _onUserUpdated(UserModel updatedUser) {
    final authState = ref.read(authControllerProvider);
    final currentUserEmail = (authState.email ?? '').trim().toLowerCase();
    final updatedEmail = updatedUser.email.trim().toLowerCase();

    if (updatedEmail == currentUserEmail) {
      state = state.copyWith(
        users: state.users.where((u) => u.id != updatedUser.id).toList(),
      );
      return;
    }

    final exists = state.users.any((u) => u.id == updatedUser.id);

    if (!exists) {
      state = state.copyWith(
        users: [updatedUser, ...state.users],
      );
      return;
    }

    final updatedList = state.users.map((user) {
      if (user.id == updatedUser.id) return updatedUser;
      return user;
    }).toList();

    state = state.copyWith(
      users: updatedList,
    );
  }

  void _onUserDeleted(String id) {
    final updatedList = state.users.where((user) => user.id != id).toList();

    state = state.copyWith(
      users: updatedList,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    socketService.off('user:created');
    socketService.off('user:updated');
    socketService.off('user:deleted');
    super.dispose();
  }
}

final usersControllerProvider =
    StateNotifierProvider<UsersController, UsersState>((ref) {
  return UsersController(
    ref,
    ref.read(usersRepositoryProvider),
    ref.read(socketServiceProvider),
  );
});