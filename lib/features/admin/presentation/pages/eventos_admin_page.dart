import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:event_app/features/events/data/models/event_model.dart';
import 'package:event_app/features/events/presentation/providers/events_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventosAdminPage extends ConsumerStatefulWidget {
  const EventosAdminPage({super.key});

  @override
  ConsumerState<EventosAdminPage> createState() => _EventosAdminPageState();
}

class _EventosAdminPageState extends ConsumerState<EventosAdminPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final authState = ref.read(authControllerProvider);
      final token = authState.token ?? '';

      if (token.isEmpty) return;

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
          event.endDate.toLowerCase().contains(text) ||
          event.startTime.toLowerCase().contains(text) ||
          event.endTime.toLowerCase().contains(text) ||
          event.location.toLowerCase().contains(text) ||
          event.createdByName.toLowerCase().contains(text) ||
          event.status.toLowerCase().contains(text);
    }).toList();
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
              child: _AdminEventosHeader(
                onBack: () => Navigator.pop(context),
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
                          'Consulta y supervisa todos los eventos registrados por los usuarios del sistema.',
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
                        _ResumenEventosAdmin(
                          total: events.length,
                          activos: events.where((e) => e.isActive).length,
                          categorias:
                              events.map((e) => e.category.id).toSet().length,
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
                        if (filteredEvents.isEmpty)
                          const _EmptyEventosState()
                        else
                          ...filteredEvents.map(
                            (evento) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _EventoAdminCard(evento: evento),
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
    );
  }
}

class _AdminEventosHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _AdminEventosHeader({
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

class _ResumenEventosAdmin extends StatelessWidget {
  final int total;
  final int activos;
  final int categorias;

  const _ResumenEventosAdmin({
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

class _EventoAdminCard extends StatelessWidget {
  final EventModel evento;

  const _EventoAdminCard({
    required this.evento,
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
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoBadge(
                label: evento.categoryName,
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
              _InfoBadge(
  label: _buildStatusLabel(evento.status),
  color: const Color(0xFF3557D6),
  background: const Color(0xFFEAF0FF),
),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: Color(0xFF2D4ECF),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  evento.createdByName.isEmpty
                      ? 'Sin creador'
                      : evento.createdByName,
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
        hintText:
            'Buscar por título, categoría, fecha, hora, ubicación o creador',
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

class _EmptyEventosState extends StatelessWidget {
  const _EmptyEventosState();

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
            'No hay eventos para mostrar con los filtros actuales.',
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
String _buildStatusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'upcoming':
      return 'Próximo';
    case 'completed':
      return 'Completado';
    case 'cancelled':
      return 'Cancelado';
    default:
      return status;
  }
}