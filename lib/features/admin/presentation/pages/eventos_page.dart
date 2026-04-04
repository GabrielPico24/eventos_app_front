/* import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:event_app/features/categories/data/models/category_model.dart';
import 'package:event_app/features/categories/presentation/providers/categories_provider.dart';
import 'package:event_app/features/events/data/models/event_model.dart';
import 'package:event_app/features/events/presentation/providers/events_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyEventsPage extends ConsumerStatefulWidget {
  const EventosPage({super.key});

  @override
  ConsumerState<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends ConsumerState<EventosPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final authState = ref.read(authControllerProvider);
      final token = authState.token ?? '';

      if (token.isEmpty) return;

      ref.read(categoriesProvider.notifier).loadCategories(token: token);
      ref.read(eventsProvider.notifier).loadEvents(token: token);
    });
  }

  List<EventModel> _applyFilter(List<EventModel> events) {
    if (_searchText.trim().isEmpty) return events;

    final text = _searchText.toLowerCase().trim();

    return events.where((event) {
      return event.title.toLowerCase().contains(text) ||
          event.categoryName.toLowerCase().contains(text) ||
          event.startDate.toLowerCase().contains(text) ||
          event.startTime.toLowerCase().contains(text) ||
          event.location.toLowerCase().contains(text);
    }).toList();
  }

  Future<void> _openEventoDialog({
    EventModel? evento,
  }) async {
    final isEdit = evento != null;

    final tituloController =
        TextEditingController(text: isEdit ? evento.title : '');
    final descripcionController =
        TextEditingController(text: isEdit ? evento.description : '');
    final fechaInicioController =
        TextEditingController(text: isEdit ? evento.startDate : '');
    final fechaFinController =
        TextEditingController(text: isEdit ? evento.endDate : '');
    final horaInicioController =
        TextEditingController(text: isEdit ? evento.startTime : '');
    final horaFinController =
        TextEditingController(text: isEdit ? evento.endTime : '');
    final ubicacionController =
        TextEditingController(text: isEdit ? evento.location : '');

    bool activo = isEdit ? evento.isActive : true;
    String? categoriaSeleccionadaId = isEdit ? evento.category.id : null;

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    final categoriesState = ref.read(categoriesProvider);

    final categories = categoriesState.maybeWhen(
      data: (data) => data
          .where((e) => e.isActive || e.id == categoriaSeleccionadaId)
          .toList(),
      orElse: () => <CategoryModel>[],
    );

    if (categories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Primero debes crear al menos una categoría'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    categoriaSeleccionadaId ??= categories.first.id;

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
                                  isEdit ? 'Editar evento' : 'Nuevo evento',
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
                                    isEdit
                                        ? 'Modifica la información del evento seleccionado.'
                                        : 'Completa la información para registrar un nuevo evento.',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF8B90A0),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  const _InputLabel('Título del evento'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: tituloController,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: _inputDecoration(
                                      hint: 'Ingresa el título',
                                      icon: Icons.event_note_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'El título es obligatorio';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  const _InputLabel('Categoría'),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F8FC),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xFFE8EBF3),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: categoriaSeleccionadaId,
                                        isExpanded: true,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Color(0xFF2D4ECF),
                                        ),
                                        items: categories.map((categoria) {
                                          return DropdownMenuItem<String>(
                                            value: categoria.id,
                                            child: Text(categoria.name),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value == null) return;
                                          setModalState(() {
                                            categoriaSeleccionadaId = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const _InputLabel('Fecha inicio'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: fechaInicioController,
                                    keyboardType: TextInputType.datetime,
                                    decoration: _inputDecoration(
                                      hint: 'Ej: 25/03/2026',
                                      icon: Icons.calendar_month_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'La fecha de inicio es obligatoria';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  const _InputLabel('Fecha fin'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: fechaFinController,
                                    keyboardType: TextInputType.datetime,
                                    decoration: _inputDecoration(
                                      hint: 'Ej: 25/03/2026',
                                      icon: Icons.event_available_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'La fecha de fin es obligatoria';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  const _InputLabel('Hora inicio'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: horaInicioController,
                                    keyboardType: TextInputType.datetime,
                                    decoration: _inputDecoration(
                                      hint: 'Ej: 09:00 AM',
                                      icon: Icons.access_time_rounded,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'La hora de inicio es obligatoria';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  const _InputLabel('Hora fin'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: horaFinController,
                                    keyboardType: TextInputType.datetime,
                                    decoration: _inputDecoration(
                                      hint: 'Ej: 10:00 AM',
                                      icon: Icons.schedule_rounded,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'La hora de fin es obligatoria';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  const _InputLabel('Ubicación'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: ubicacionController,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: _inputDecoration(
                                      hint: 'Ej: Sala principal',
                                      icon: Icons.location_on_outlined,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const _InputLabel('Descripción'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: descripcionController,
                                    maxLines: 4,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: _inputDecoration(
                                      hint: 'Describe el evento',
                                      icon: Icons.description_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'La descripción es obligatoria';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
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
                                          child: Text(
                                            'Evento activo',
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF181A20),
                                            ),
                                          ),
                                        ),
                                        Switch(
                                          value: activo,
                                          activeColor: const Color(0xFF2D4ECF),
                                          onChanged: (value) {
                                            setModalState(() {
                                              activo = value;
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

                                              final authState = ref
                                                  .read(authControllerProvider);
                                              final token =
                                                  authState.token ?? '';

                                              if (token.isEmpty) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Sesión no válida. Inicia sesión nuevamente',
                                                      ),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                }
                                                return;
                                              }

                                              final categoriaSeleccionada =
                                                  categories.firstWhere(
                                                (c) =>
                                                    c.id ==
                                                    categoriaSeleccionadaId,
                                              );

                                              try {
                                                setModalState(() {
                                                  isSaving = true;
                                                });

                                                if (isEdit) {
                                                  await ref
                                                      .read(eventsProvider
                                                          .notifier)
                                                      .updateEvent(
                                                        token: token,
                                                        id: evento.id,
                                                        title: tituloController
                                                            .text
                                                            .trim(),
                                                        categoryId:
                                                            categoriaSeleccionada
                                                                .id,
                                                        categoryName:
                                                            categoriaSeleccionada
                                                                .name,
                                                        description:
                                                            descripcionController
                                                                .text
                                                                .trim(),
                                                        startDate:
                                                            fechaInicioController
                                                                .text
                                                                .trim(),
                                                        endDate:
                                                            fechaFinController
                                                                .text
                                                                .trim(),
                                                        startTime:
                                                            horaInicioController
                                                                .text
                                                                .trim(),
                                                        endTime:
                                                            horaFinController
                                                                .text
                                                                .trim(),
                                                        location:
                                                            ubicacionController
                                                                .text
                                                                .trim(),
                                                        isActive: activo,
                                                      );
                                                } else {
                                                  await ref
                                                      .read(eventsProvider
                                                          .notifier)
                                                      .createEvent(
                                                        token: token,
                                                        title: tituloController
                                                            .text
                                                            .trim(),
                                                        categoryId:
                                                            categoriaSeleccionada
                                                                .id,
                                                        categoryName:
                                                            categoriaSeleccionada
                                                                .name,
                                                        description:
                                                            descripcionController
                                                                .text
                                                                .trim(),
                                                        startDate:
                                                            fechaInicioController
                                                                .text
                                                                .trim(),
                                                        endDate:
                                                            fechaFinController
                                                                .text
                                                                .trim(),
                                                        startTime:
                                                            horaInicioController
                                                                .text
                                                                .trim(),
                                                        endTime:
                                                            horaFinController
                                                                .text
                                                                .trim(),
                                                        location:
                                                            ubicacionController
                                                                .text
                                                                .trim(),
                                                        isActive: activo,
                                                      );
                                                }

                                                if (mounted) {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        isEdit
                                                            ? 'Evento actualizado correctamente'
                                                            : 'Evento creado correctamente',
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
                                                                ''),
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
                                            : isEdit
                                                ? 'Guardar cambios'
                                                : 'Crear evento',
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

  Future<void> _toggleEventoStatus(EventModel evento) async {
    final nuevoEstado = !evento.isActive;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          nuevoEstado ? 'Activar evento' : 'Inactivar evento',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          nuevoEstado
              ? '¿Deseas activar el evento "${evento.title}"?'
              : '¿Deseas inactivar el evento "${evento.title}"?',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D4ECF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(nuevoEstado ? 'Activar' : 'Inactivar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final authState = ref.read(Provider);
      final token = authState.token ?? '';

      if (token.isEmpty) {
        throw Exception('Sesión no válida. Inicia sesión nuevamente');
      }

      await ref.read(eventsProvider.notifier).toggleEventStatus(
            token: token,
            id: evento.id,
            isActive: nuevoEstado,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nuevoEstado
                  ? 'Evento activado correctamente'
                  : 'Evento inactivado correctamente',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: _EventosHeader(
                onBack: () => Navigator.pop(context),
                onAdd: () => _openEventoDialog(),
              ),
            ),
            Expanded(
              child: eventsState.when(
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
                          Icons.event_busy_outlined,
                          size: 56,
                          color: Color(0xFF8B90A0),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No se pudieron cargar los eventos',
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
                                .read(eventsProvider.notifier)
                                .loadEvents(token: token);
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
                data: (events) {
                  final filteredEvents = _applyFilter(events);

                  return RefreshIndicator(
                    onRefresh: () async {
                      final authState = ref.read(authControllerProvider);
                      final token = authState.token ?? '';

                      if (token.isEmpty) return;

                      await ref
                          .read(categoriesProvider.notifier)
                          .loadCategories(token: token);
                      await ref
                          .read(eventsProvider.notifier)
                          .loadEvents(token: token);
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        const SizedBox(height: 6),
                        const Text(
                          'Eventos',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF181A20),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Administra los eventos y servicios disponibles dentro de la aplicación.',
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
                        _ResumenEventos(
                          total: events.length,
                          activos: events.where((e) => e.isActive).length,
                          categorias:
                              events.map((e) => e.category.id).toSet().length,
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Listado de eventos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF181A20),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (filteredEvents.isEmpty)
                          const _EmptyEventosState()
                        else
                          ...filteredEvents.map(
                            (evento) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _EventoCard(
                                evento: evento,
                                onEdit: () => _openEventoDialog(evento: evento),
                                onDelete: () => _toggleEventoStatus(evento),
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
        onPressed: () => _openEventoDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
}

class _EventosHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onAdd;

  const _EventosHeader({
    required this.onBack,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: onBack,
        ),
        const Spacer(),
        _HeaderButton(
          icon: Icons.add_rounded,
          onTap: onAdd,
        ),
      ],
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
        hintText: 'Buscar por título, categoría, fecha, hora o ubicación',
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

class _ResumenEventos extends StatelessWidget {
  final int total;
  final int activos;
  final int categorias;

  const _ResumenEventos({
    required this.total,
    required this.activos,
    required this.categorias,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniResumenCard(
            title: 'Total',
            value: '$total',
            icon: Icons.event_note_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniResumenCard(
            title: 'Activos',
            value: '$activos',
            icon: Icons.verified_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniResumenCard(
            title: 'Categorías',
            value: '$categorias',
            icon: Icons.category_outlined,
          ),
        ),
      ],
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

class _EventoCard extends StatelessWidget {
  final EventModel evento;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventoCard({
    required this.evento,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final estadoColor =
        evento.isActive ? const Color(0xFF2D4ECF) : const Color(0xFF9EA4B5);

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
                  Icons.event_note_outlined,
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
                      evento.title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF181A20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      evento.description,
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
                  if (value == 'estado') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'editar',
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: 'estado',
                    child: Text(evento.isActive ? 'Inactivar' : 'Activar'),
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
                label: evento.category.name,
                color: const Color(0xFF2D4ECF),
                background: const Color(0xFFEAF0FF),
              ),
              _InfoBadge(
                label: evento.isActive ? 'Activo' : 'Inactivo',
                color: estadoColor,
                background: evento.isActive
                    ? const Color(0xFFEAF0FF)
                    : const Color(0xFFF0F2F7),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: Color(0xFF2D4ECF),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${evento.startDate} - ${evento.endDate}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF4D5875),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 18,
                color: Color(0xFF2D4ECF),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${evento.startTime} - ${evento.endTime}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF4D5875),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (evento.location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Color(0xFF2D4ECF),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    evento.location,
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

class _EmptyEventosState extends StatelessWidget {
  const _EmptyEventosState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EBF3)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 54,
            color: Color(0xFF2D4ECF),
          ),
          SizedBox(height: 12),
          Text(
            'No se encontraron eventos',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF181A20),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Intenta con otro criterio de búsqueda o crea un nuevo evento.',
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
 */
