import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/core/config/env.dart';
import 'package:event_app/core/providers/app_providers.dart';
import 'package:event_app/core/services/socket_service.dart';
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
      remote,
      socketService,
    );

    ref.onDispose(() {
      notifier.disposeSocketListeners();
    });

    return notifier;
  },
);

class CategoriesNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final CategoriesRemoteDataSource remote;
  final SocketService socketService;

  bool _socketListenersInitialized = false;

  CategoriesNotifier(this.remote, this.socketService)
      : super(const AsyncValue.loading());

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

      _initSocketListeners();
    } catch (e, st) {
      print('❌ error en loadCategories => $e');
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
    await remote.createCategory(
      token: token,
      payload: {
        'name': name,
        'description': description,
        'isActive': isActive,
      },
    );
  }

  Future<void> updateCategory({
    required String token,
    required String id,
    required String name,
    required String description,
    required bool isActive,
  }) async {
    await remote.updateCategory(
      token: token,
      id: id,
      payload: {
        'name': name,
        'description': description,
        'isActive': isActive,
      },
    );
  }

  Future<void> deleteCategory({
    required String token,
    required String id,
  }) async {
    await remote.deleteCategory(
      token: token,
      id: id,
    );
  }

  void _initSocketListeners() {
    if (_socketListenersInitialized) return;
    _socketListenersInitialized = true;

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
        final id = map['id']?.toString();

        if (id == null || id.isEmpty) return;

        _removeCategory(id);
      } catch (e) {
        print('❌ Error procesando category:deleted => $e');
      }
    });
  }

  void _addCategory(CategoryModel category) {
    final current = state.value ?? [];

    final exists = current.any((item) => item.id == category.id);
    if (exists) return;

    final updated = [...current, category];
    state = AsyncValue.data(updated);
  }

  void _replaceCategory(CategoryModel category) {
    final current = state.value ?? [];

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
    _socketListenersInitialized = false;
  }
}