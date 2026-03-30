import 'package:flutter/material.dart';

class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<EventoModel> _eventos = [
    EventoModel(
      id: '1',
      titulo: 'Cita médica general',
      categoria: 'Cita médica',
      fecha: '25/03/2026',
      hora: '09:00 AM',
      cupos: 12,
      activo: true,
      descripcion: 'Atención médica general para usuarios registrados.',
    ),
    EventoModel(
      id: '2',
      titulo: 'Sesión de psicología',
      categoria: 'Psicólogo',
      fecha: '26/03/2026',
      hora: '10:30 AM',
      cupos: 8,
      activo: true,
      descripcion: 'Atención psicológica individual con agenda previa.',
    ),
    EventoModel(
      id: '3',
      titulo: 'Campaña de vacunación',
      categoria: 'Vacunación',
      fecha: '27/03/2026',
      hora: '08:00 AM',
      cupos: 30,
      activo: false,
      descripcion: 'Jornada preventiva de vacunación para usuarios.',
    ),
    EventoModel(
      id: '4',
      titulo: 'Aplicación de inyección',
      categoria: 'Inyección',
      fecha: '28/03/2026',
      hora: '11:00 AM',
      cupos: 15,
      activo: true,
      descripcion: 'Servicio de inyección programada según cita.',
    ),
  ];

  String _searchText = '';

  List<EventoModel> get _filteredEventos {
    if (_searchText.trim().isEmpty) return _eventos;

    return _eventos.where((evento) {
      final text = _searchText.toLowerCase();
      return evento.titulo.toLowerCase().contains(text) ||
          evento.categoria.toLowerCase().contains(text) ||
          evento.fecha.toLowerCase().contains(text) ||
          evento.hora.toLowerCase().contains(text);
    }).toList();
  }

  void _openEventoDialog({EventoModel? evento}) {
    final isEdit = evento != null;

    final tituloController =
        TextEditingController(text: isEdit ? evento.titulo : '');
    final descripcionController =
        TextEditingController(text: isEdit ? evento.descripcion : '');
    final fechaController =
        TextEditingController(text: isEdit ? evento.fecha : '');
    final horaController =
        TextEditingController(text: isEdit ? evento.hora : '');
    final cuposController =
        TextEditingController(text: isEdit ? evento.cupos.toString() : '');

    String categoriaSeleccionada =
        isEdit ? evento.categoria : 'Cita médica';
    bool activo = isEdit ? evento.activo : true;

    final formKey = GlobalKey<FormState>();

    const categorias = [
      'Psicólogo',
      'Inyección',
      'Cita médica',
      'Odontología',
      'Laboratorio',
      'Control general',
      'Vacunación',
      'Terapia',
    ];

    showModalBottomSheet(
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
        final maxHeight = mediaQuery.size.height * 0.90;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El título es obligatorio';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const _InputLabel('Categoría'),
                              const SizedBox(height: 8),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F8FC),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFE8EBF3),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: categoriaSeleccionada,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF2D4ECF),
                                    ),
                                    items: categorias
                                        .map(
                                          (categoria) => DropdownMenuItem(
                                            value: categoria,
                                            child: Text(categoria),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setModalState(() {
                                        categoriaSeleccionada = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const _InputLabel('Fecha'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: fechaController,
                                keyboardType: TextInputType.datetime,
                                decoration: _inputDecoration(
                                  hint: 'Ej: 25/03/2026',
                                  icon: Icons.calendar_month_outlined,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'La fecha es obligatoria';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const _InputLabel('Hora'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: horaController,
                                keyboardType: TextInputType.datetime,
                                decoration: _inputDecoration(
                                  hint: 'Ej: 09:00 AM',
                                  icon: Icons.access_time_rounded,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'La hora es obligatoria';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const _InputLabel('Cupos disponibles'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: cuposController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(
                                  hint: 'Ingresa el número de cupos',
                                  icon: Icons.groups_outlined,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Los cupos son obligatorios';
                                  }
                                  if (int.tryParse(value.trim()) == null) {
                                    return 'Ingresa un número válido';
                                  }
                                  return null;
                                },
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
                                  if (value == null || value.trim().isEmpty) {
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
                                    backgroundColor: const Color(0xFF2D4ECF),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }

                                    if (isEdit) {
                                      setState(() {
                                        final index = _eventos.indexWhere(
                                          (e) => e.id == evento.id,
                                        );

                                        if (index != -1) {
                                          _eventos[index] = EventoModel(
                                            id: evento.id,
                                            titulo:
                                                tituloController.text.trim(),
                                            categoria: categoriaSeleccionada,
                                            fecha: fechaController.text.trim(),
                                            hora: horaController.text.trim(),
                                            cupos: int.parse(
                                              cuposController.text.trim(),
                                            ),
                                            activo: activo,
                                            descripcion: descripcionController
                                                .text
                                                .trim(),
                                          );
                                        }
                                      });
                                    } else {
                                      setState(() {
                                        _eventos.insert(
                                          0,
                                          EventoModel(
                                            id: DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString(),
                                            titulo:
                                                tituloController.text.trim(),
                                            categoria: categoriaSeleccionada,
                                            fecha: fechaController.text.trim(),
                                            hora: horaController.text.trim(),
                                            cupos: int.parse(
                                              cuposController.text.trim(),
                                            ),
                                            activo: activo,
                                            descripcion: descripcionController
                                                .text
                                                .trim(),
                                          ),
                                        );
                                      });
                                    }

                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEdit
                                              ? 'Evento actualizado correctamente'
                                              : 'Evento creado correctamente',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    isEdit
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

  void _deleteEvento(EventoModel evento) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Eliminar evento',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          '¿Deseas eliminar el evento "${evento.titulo}"?',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
            onPressed: () {
              setState(() {
                _eventos.removeWhere((e) => e.id == evento.id);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Evento eliminado correctamente'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 700;
    final padding = width * 0.06;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(padding, 14, padding, 12),
              child: _EventosHeader(
                onBack: () => Navigator.pop(context),
                onAdd: () => _openEventoDialog(),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(padding, 0, padding, 24),
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
                  const SizedBox(height: 18),
                  _ResumenEventos(
                    total: _eventos.length,
                    activos: _eventos.where((e) => e.activo).length,
                    categorias: _eventos.map((e) => e.categoria).toSet().length,
                    isTablet: isTablet,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Listado de eventos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF181A20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_filteredEventos.isEmpty)
                    const _EmptyEventosState()
                  else
                    ..._filteredEventos.map(
                      (evento) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EventoCard(
                          evento: evento,
                          onEdit: () => _openEventoDialog(evento: evento),
                          onDelete: () => _deleteEvento(evento),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: width < 700
          ? FloatingActionButton(
              elevation: 0,
              backgroundColor: const Color(0xFF2D4ECF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              onPressed: () => _openEventoDialog(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
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
        MediaQuery.of(context).size.width >= 700
            ? _PrimaryHeaderButton(
                icon: Icons.event_available_outlined,
                label: 'Nuevo evento',
                onTap: onAdd,
              )
            : _HeaderButton(
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

class _PrimaryHeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryHeaderButton({
    required this.icon,
    required this.label,
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF2D4ECF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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
        hintText: 'Buscar por título, categoría, fecha u hora',
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
  final bool isTablet;

  const _ResumenEventos({
    required this.total,
    required this.activos,
    required this.categorias,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MiniResumenCard(
        title: 'Total',
        value: '$total',
        icon: Icons.event_note_outlined,
      ),
      _MiniResumenCard(
        title: 'Activos',
        value: '$activos',
        icon: Icons.verified_outlined,
      ),
      _MiniResumenCard(
        title: 'Categorías',
        value: '$categorias',
        icon: Icons.category_outlined,
      ),
    ];

    if (isTablet) {
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 10),
          Expanded(child: cards[1]),
          const SizedBox(width: 10),
          Expanded(child: cards[2]),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 10),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 10),
        cards[2],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EBF3)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2D4ECF),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF181A20),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF8B90A0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventoCard extends StatelessWidget {
  final EventoModel evento;
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
        evento.activo ? const Color(0xFF2D4ECF) : const Color(0xFF9EA4B5);

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
                      evento.titulo,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF181A20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      evento.descripcion,
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
                label: evento.categoria,
                color: const Color(0xFF2D4ECF),
                background: const Color(0xFFEAF0FF),
              ),
              _InfoBadge(
                label: evento.activo ? 'Activo' : 'Inactivo',
                color: estadoColor,
                background: evento.activo
                    ? const Color(0xFFEAF0FF)
                    : const Color(0xFFF0F2F7),
              ),
              _InfoBadge(
                label: '${evento.cupos} cupos',
                color: const Color(0xFF4D5875),
                background: const Color(0xFFF0F2F7),
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
              Text(
                evento.fecha,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF4D5875),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time_rounded,
                size: 18,
                color: Color(0xFF2D4ECF),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  evento.hora,
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

class EventoModel {
  final String id;
  final String titulo;
  final String categoria;
  final String fecha;
  final String hora;
  final int cupos;
  final bool activo;
  final String descripcion;

  EventoModel({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.fecha,
    required this.hora,
    required this.cupos,
    required this.activo,
    required this.descripcion,
  });
}