import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:event_app/features/categories/data/models/category_model.dart';

final categoriesRemoteDataSourceProvider =
    Provider<CategoriesRemoteDataSource>((ref) {
  return CategoriesRemoteDataSource(
    baseUrl: 'http://192.168.200.10:3000',
  );
});

final categoriesProvider = StateNotifierProvider.autoDispose<
    CategoriesNotifier, AsyncValue<List<CategoryModel>>>((ref) {
  final remote = ref.read(categoriesRemoteDataSourceProvider);
  return CategoriesNotifier(remote);
});

class CategoriesNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final CategoriesRemoteDataSource remote;

  CategoriesNotifier(this.remote) : super(const AsyncValue.loading());

  Future<void> loadCategories({
    required String token,
  }) async {
    try {
      state = const AsyncValue.loading();
      final categories = await remote.getCategories(token: token);
      state = AsyncValue.data(categories);
    } catch (e, st) {
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

    await loadCategories(token: token);
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

    await loadCategories(token: token);
  }

  Future<void> deleteCategory({
    required String token,
    required String id,
  }) async {
    await remote.deleteCategory(
      token: token,
      id: id,
    );

    await loadCategories(token: token);
  }
}