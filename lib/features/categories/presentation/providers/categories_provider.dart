import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/core/config/env.dart';
import 'package:event_app/core/providers/app_providers.dart';
import 'package:event_app/core/services/socket_service.dart';
import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:event_app/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:event_app/features/categories/data/models/category_model.dart';

final categoriesRemoteDataSourceProvider =
    Provider<CategoriesRemoteDataSource>((ref) {
  return CategoriesRemoteDataSource(
    baseUrl: Env.baseUrl,
  );
});

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, AsyncValue<List<CategoryModel>>>(
  (ref) {
    final remote = ref.read(categoriesRemoteDataSourceProvider);
    final socketService = ref.read(socketServiceProvider);

    final notifier = CategoriesNotifier(
      ref,
      remote,
      socketService,
    );

    ref.onDispose(() {
      notifier.disposeSocketListeners();
    });

    return notifier;
  },
);

class CategoriesNotifier
    extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final Ref ref;
  final CategoriesRemoteDataSource remote;
  final SocketService socketService;

  bool _socketListenersInitialized = false;

  CategoriesNotifier(
    this.ref,
    this.remote,
    this.socketService,
  ) : super(const AsyncValue.loading()) {
    _initSocketListeners();
  }

  Future<void> loadCategories({
    required String token,
  }) async {
    try {
      print('🟡 loadCategories ejecutado');
      state = const AsyncValue.loading();

      final categories = await remote.getCategories(token: token);

      if (!mounted) return;

      print('🟢 categorías cargadas: ${categories.length}');
      state = AsyncValue.data(categories);
    } catch (e, st) {
      final message = e.toString();

      print('❌ error en loadCategories => $message');

      if (message.contains('401|')) {
        print(
          '🔒 TOKEN EXPIRADO detectado en CategoriesNotifier.loadCategories',
        );
        await ref.read(authControllerProvider.notifier).handleSessionExpired();
      }

      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createCategory({
    required String token,
    required String name,
    required String description,
    required bool isActive,
  }) async {
    try {
      await remote.createCategory(
        token: token,
        payload: {
          'name': name,
          'description': description,
          'isActive': isActive,
        },
      );
    } catch (e) {
      final message = e.toString();

      print('❌ error en createCategory => $message');

      if (message.contains('401|')) {
        print(
          '🔒 TOKEN EXPIRADO detectado en CategoriesNotifier.createCategory',
        );
        await ref.read(authControllerProvider.notifier).handleSessionExpired();
      }

      rethrow;
    }
  }

  Future<void> updateCategory({
    required String token,
    required String id,
    required String name,
    required String description,
    required bool isActive,
  }) async {
    try {
      await remote.updateCategory(
        token: token,
        id: id,
        payload: {
          'name': name,
          'description': description,
          'isActive': isActive,
        },
      );
    } catch (e) {
      final message = e.toString();

      print('❌ error en updateCategory => $message');

      if (message.contains('401|')) {
        print(
          '🔒 TOKEN EXPIRADO detectado en CategoriesNotifier.updateCategory',
        );
        await ref.read(authControllerProvider.notifier).handleSessionExpired();
      }

      rethrow;
    }
  }

  Future<void> deleteCategory({
    required String token,
    required String id,
  }) async {
    try {
      await remote.deleteCategory(
        token: token,
        id: id,
      );
    } catch (e) {
      final message = e.toString();

      print('❌ error en deleteCategory => $message');

      if (message.contains('401|')) {
        print(
          '🔒 TOKEN EXPIRADO detectado en CategoriesNotifier.deleteCategory',
        );
        await ref.read(authControllerProvider.notifier).handleSessionExpired();
      }

      rethrow;
    }
  }

  void _initSocketListeners() {
    if (_socketListenersInitialized) return;
    _socketListenersInitialized = true;

    socketService.off('category:created');
    socketService.off('category:updated');
    socketService.off('category:deleted');

    print('✅ Listeners de categorías registrados');

    socketService.on('category:created', (data) {
      try {
        print('📩 socket category:created => $data');

        final category = CategoryModel.fromJson(
          Map<String, dynamic>.from(data),
        );

        _addCategory(category);
      } catch (e) {
        print('❌ Error procesando category:created => $e');
      }
    });

    socketService.on('category:updated', (data) {
      try {
        print('📩 socket category:updated => $data');

        final category = CategoryModel.fromJson(
          Map<String, dynamic>.from(data),
        );

        _replaceCategory(category);
      } catch (e) {
        print('❌ Error procesando category:updated => $e');
      }
    });

    socketService.on('category:deleted', (data) {
      try {
        print('📩 socket category:deleted => $data');

        final map = Map<String, dynamic>.from(data);
        final id = map['id']?.toString() ?? map['_id']?.toString();

        if (id == null || id.isEmpty) return;

        _removeCategory(id);
      } catch (e) {
        print('❌ Error procesando category:deleted => $e');
      }
    });
  }

  void rebindSocketListeners() {
    print('🔄 Reenlazando listeners de categorías...');
    _socketListenersInitialized = false;
    _initSocketListeners();
  }

  void _addCategory(CategoryModel category) {
    final current = state.value ?? [];

    final exists = current.any((item) => item.id == category.id);
    if (exists) return;

    final updated = [category, ...current];
    state = AsyncValue.data(updated);
  }

  void _replaceCategory(CategoryModel category) {
    final current = state.value ?? [];

    final exists = current.any((item) => item.id == category.id);

    if (!exists) {
      state = AsyncValue.data([category, ...current]);
      return;
    }

    final updated = current.map((item) {
      if (item.id == category.id) {
        return category;
      }
      return item;
    }).toList();

    state = AsyncValue.data(updated);
  }

  void _removeCategory(String id) {
    final current = state.value ?? [];
    final updated = current.where((item) => item.id != id).toList();

    state = AsyncValue.data(updated);
  }

  void disposeSocketListeners() {
    socketService.off('category:created');
    socketService.off('category:updated');
    socketService.off('category:deleted');
  }
}