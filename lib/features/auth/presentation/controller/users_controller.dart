import 'package:event_app/features/auth/data/datasource/users_remote_datasource.dart';
import 'package:event_app/features/auth/data/repositories/users_repository.dart';
import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:event_app/features/auth/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersState {
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final String? errorMessage;
  final List<UserModel> users;
final bool isDeleting;
  const UsersState({
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.errorMessage,
    this.users = const [],
    this.isDeleting = false,
  });

  UsersState copyWith({
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    String? errorMessage,
    List<UserModel>? users,
    bool? isDeleting,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage,
      users: users ?? this.users,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

final usersRemoteDataSourceProvider = Provider<UsersRemoteDataSource>((ref) {
  return UsersRemoteDataSource(
    baseUrl: 'http://192.168.200.10:3000',
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

  UsersController(this.ref, this.repository) : super(const UsersState());

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

    final currentUserEmail =
        (authState.email ?? '').trim().toLowerCase();

    final filteredUsers = users.where((user) {
      final userEmail = user.email.trim().toLowerCase();
      return userEmail != currentUserEmail;
    }).toList();

    state = state.copyWith(
      isLoading: false,
      users: filteredUsers,
    );
  } catch (e) {
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

      state = state.copyWith(
        isCreating: false,
        users: [createdUser, ...state.users],
      );
    } catch (e) {
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

      final updatedUser = await repository.updateUser(
        token: token,
        id: id,
        name: name,
        email: email,
        password: password,
        role: role,
        isActive: isActive,
      );

      final updatedList = state.users.map((user) {
        if (user.id == id) return updatedUser;
        return user;
      }).toList();

      state = state.copyWith(
        isUpdating: false,
        users: updatedList,
      );
    } catch (e) {
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
    final currentUserEmail =
        (authState.email ?? '').trim().toLowerCase();

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

    final updatedList = state.users.where((user) => user.id != id).toList();

    state = state.copyWith(
      isDeleting: false,
      users: updatedList,
    );
  } catch (e) {
    state = state.copyWith(
      isDeleting: false,
      errorMessage: e.toString().replaceFirst('Exception: ', ''),
    );
    rethrow;
  }
}

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final usersControllerProvider =
    StateNotifierProvider<UsersController, UsersState>((ref) {
  return UsersController(ref, ref.read(usersRepositoryProvider));
});