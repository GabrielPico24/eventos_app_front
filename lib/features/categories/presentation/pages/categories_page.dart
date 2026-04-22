import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:event_app/features/categories/data/models/category_model.dart';
import 'package:event_app/features/categories/presentation/providers/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authState = ref.read(authControllerProvider);
      final token = authState.token ?? '';

      if (token.isEmpty) return;

      ref.read(categoriesProvider.notifier).loadCategories(
        token: token,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryModel> _applyFilter(List<CategoryModel> categories) {
    if (_searchText.trim().isEmpty) return categories;

    final text = _searchText.toLowerCase().trim();

    return categories.where((category) {
      return category.name.toLowerCase().contains(text) ||
          category.description.toLowerCase().contains(text) ||
          (category.isActive ? 'activa' : 'inactiva').contains(text);
    }).toList();
  }

  Future<void> _openCategoryForm({
    CategoryModel? category,
  }) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController =
        TextEditingController(text: category?.description ?? '');
    bool isActive = category?.isActive ?? true;
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final mediaQuery = MediaQuery.of(context);
            final bottomInset = mediaQuery.viewInsets.bottom;
            final maxHeight = mediaQuery.size.height * 0.92;

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Container(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            width: 46,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7DBE8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category == null
                                      ? 'Nueva categoría'
                                      : 'Editar categoría',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF181A20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                            child: Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category == null
                                        ? 'Completa la información para registrar una nueva categoría.'
                                        : 'Modifica la información de la categoría seleccionada.',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF8B90A0),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  const _InputLabel('Nombre de la categoría'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: nameController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: _inputDecoration(
                                      hint: 'Ej: Odontología',
                                      icon: Icons.category_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'El nombre es obligatorio';
                                      }
                                      if (value.trim().length < 3) {
                                        return 'Debe tener al menos 3 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  const _InputLabel('Descripción'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: descriptionController,
                                    minLines: 3,
                                    maxLines: 4,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: _inputDecoration(
                                      hint: 'Describe la categoría',
                                      icon: Icons.description_outlined,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F8FC),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xFFE8EBF3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Categoría activa',
                                                style: TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF181A20),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Las categorías inactivas no deberían usarse para nuevos eventos.',
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  height: 1.35,
                                                  color: Color(0xFF8B90A0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          value: isActive,
                                          activeColor: const Color(0xFF2D4ECF),
                                          onChanged: (value) {
                                            setModalState(() {
                                              isActive = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2D4ECF),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: isSaving
                                          ? null
                                          : () async {
                                              if (!formKey.currentState!
                                                  .validate()) {
                                                return;
                                              }

                                              try {
                                                setModalState(() {
                                                  isSaving = true;
                                                });

                                                final authState = ref.read(
                                                  authControllerProvider,
                                                );
                                                final token =
                                                    authState.token ?? '';

                                                if (token.isEmpty) {
                                                  throw Exception(
                                                    'Sesión no válida. Inicia sesión nuevamente',
                                                  );
                                                }

                                                if (category == null) {
                                                  await ref
                                                      .read(categoriesProvider
                                                          .notifier)
                                                      .createCategory(
                                                        token: token,
                                                        name: nameController.text
                                                            .trim(),
                                                        description:
                                                            descriptionController
                                                                .text
                                                                .trim(),
                                                        isActive: isActive,
                                                      );
                                                } else {
                                                  await ref
                                                      .read(categoriesProvider
                                                          .notifier)
                                                      .updateCategory(
                                                        token: token,
                                                        id: category.id,
                                                        name: nameController
                                                            .text
                                                            .trim(),
                                                        description:
                                                            descriptionController
                                                                .text
                                                                .trim(),
                                                        isActive: isActive,
                                                      );
                                                }

                                                if (mounted) {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        category == null
                                                            ? 'Categoría creada correctamente'
                                                            : 'Categoría actualizada correctamente',
                                                      ),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                setModalState(() {
                                                  isSaving = false;
                                                });

                                                if (mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        e
                                                            .toString()
                                                            .replaceFirst(
                                                              'Exception: ',
                                                              '',
                                                            ),
                                                      ),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                      child: Text(
                                        isSaving
                                            ? 'Guardando...'
                                            : category == null
                                                ? 'Crear categoría'
                                                : 'Guardar cambios',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

Future<void> _confirmDelete(CategoryModel category) async {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔴 ICONO SUPERIOR
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFE53935),
                size: 32,
              ),
            ),

            const SizedBox(height: 18),

            // 🔤 TÍTULO
            const Text(
              'Eliminar categoría',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF181A20),
              ),
            ),

            const SizedBox(height: 10),

            // 📄 MENSAJE
            Text(
              '¿Deseas eliminar "${category.name}"?\nEsta acción no se puede deshacer.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8B90A0),
                height: 1.45,
              ),
            ),

            const SizedBox(height: 24),

            // 🔘 BOTONES
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE8EBF3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Color(0xFF181A20),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(this.context);
                        final navigator = Navigator.of(context);

                        try {
                          navigator.pop();

                          final authState =
                              ref.read(authControllerProvider);
                          final token = authState.token ?? '';

                          if (token.isEmpty) {
                            throw Exception(
                                'Sesión no válida. Inicia sesión nuevamente');
                          }

                          await ref
                              .read(categoriesProvider.notifier)
                              .deleteCategory(
                                token: token,
                                id: category.id,
                              );

                          if (!mounted) return;

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                '${category.name} eliminada correctamente'
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString()
                                    .replaceFirst('Exception: ', ''),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFA1A7B8),
        fontSize: 15,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFA1A7B8),
      ),
      filled: true,
      fillColor: const Color(0xFFF7F8FC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE8EBF3),
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE8EBF3),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFF2D4ECF),
          width: 1.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: _AdminCategoriasHeader(
                onBack: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: categoriesState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.folder_off_outlined,
                          size: 56,
                          color: Color(0xFF8B90A0),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No se pudieron cargar las categorías',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF181A20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString().replaceFirst('Exception: ', ''),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8B90A0),
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: () async {
                            final authState = ref.read(authControllerProvider);
                            final token = authState.token ?? '';

                            if (token.isEmpty) return;

                            await ref
                                .read(categoriesProvider.notifier)
                                .loadCategories(token: token);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D4ECF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Reintentar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (categories) {
                  final filteredCategories = _applyFilter(categories);

                  return RefreshIndicator(
                    onRefresh: () async {
                      final authState = ref.read(authControllerProvider);
                      final token = authState.token ?? '';

                      if (token.isEmpty) return;

                      await ref
                          .read(categoriesProvider.notifier)
                          .loadCategories(token: token);
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        const SizedBox(height: 6),
                        const Text(
                          'Categorías',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF181A20),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Consulta y administra las categorías disponibles para clasificar los eventos del sistema.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8B90A0),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _SearchField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchText = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _ResumenCategoriasAdmin(
                          total: categories.length,
                          activas:
                              categories.where((e) => e.isActive).length,
                          inactivas:
                              categories.where((e) => !e.isActive).length,
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Listado general',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF181A20),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (filteredCategories.isEmpty)
                          const _EmptyCategoriasState()
                        else
                          ...filteredCategories.map(
                            (category) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CategoriaAdminCard(
                                category: category,
                                onEdit: () =>
                                    _openCategoryForm(category: category),
                                onDelete: () =>
                                    _confirmDelete(category),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: const Color(0xFF2D4ECF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        onPressed: () => _openCategoryForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _AdminCategoriasHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _AdminCategoriasHeader({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: onBack,
        ),
      ],
    );
  }
}

class _ResumenCategoriasAdmin extends StatelessWidget {
  final int total;
  final int activas;
  final int inactivas;

  const _ResumenCategoriasAdmin({
    required this.total,
    required this.activas,
    required this.inactivas,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniResumenCard(
            title: 'Total',
            value: '$total',
            icon: Icons.category_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniResumenCard(
            title: 'Activas',
            value: '$activas',
            icon: Icons.verified_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniResumenCard(
            title: 'Inactivas',
            value: '$inactivas',
            icon: Icons.block_outlined,
          ),
        ),
      ],
    );
  }
}

class _CategoriaAdminCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoriaAdminCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        category.isActive ? const Color(0xFF21A366) : const Color(0xFFC63D3D);

    final statusBg =
        category.isActive ? const Color(0xFFEAF8EF) : const Color(0xFFFFF1F1);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EBF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  color: Color(0xFF2D4ECF),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF181A20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description.isEmpty
                          ? 'Sin descripción'
                          : category.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF8B90A0),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (value) {
                  if (value == 'editar') onEdit();
                  if (value == 'eliminar') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: Text('Eliminar'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoBadge(
                label: category.isActive ? 'Activa' : 'Inactiva',
                color: statusColor,
                background: statusBg,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                size: 18,
                color: Color(0xFF2D4ECF),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  category.description.isEmpty
                      ? 'Sin descripción registrada'
                      : category.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF4D5875),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _InfoBadge({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MiniResumenCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniResumenCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 115,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8EBF3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2D4ECF),
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF181A20),
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B90A0),
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8EBF3)),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2D4ECF),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, descripción o estado',
        hintStyle: const TextStyle(
          color: Color(0xFFA1A7B8),
          fontSize: 15,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFFA1A7B8),
        ),
        filled: true,
        fillColor: const Color(0xFFF7F8FC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFE8EBF3),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFE8EBF3),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF2D4ECF),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _EmptyCategoriasState extends StatelessWidget {
  const _EmptyCategoriasState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE8EBF3),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 54,
            color: Color(0xFF2D4ECF),
          ),
          SizedBox(height: 12),
          Text(
            'No se encontraron categorías',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF181A20),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'No hay categorías para mostrar con los filtros actuales.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF8B90A0),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;

  const _InputLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF181A20),
      ),
    );
  }
}