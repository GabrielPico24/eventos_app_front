import 'package:flutter/material.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();

  final List<UsuarioNotificacionModel> _usuarios = [
    UsuarioNotificacionModel(
      id: '1',
      nombre: 'María López',
      correo: 'maria@eventos.com',
      rol: 'Usuario',
      activo: true,
    ),
    UsuarioNotificacionModel(
      id: '2',
      nombre: 'Carlos Ruiz',
      correo: 'carlos@eventos.com',
      rol: 'Usuario',
      activo: true,
    ),
    UsuarioNotificacionModel(
      id: '3',
      nombre: 'Ana Torres',
      correo: 'ana@eventos.com',
      rol: 'Usuario',
      activo: false,
    ),
    UsuarioNotificacionModel(
      id: '4',
      nombre: 'Luis Mena',
      correo: 'luis@eventos.com',
      rol: 'Usuario',
      activo: true,
    ),
  ];

  final List<HistorialNotificacionModel> _historial = [
    HistorialNotificacionModel(
      titulo: 'Recordatorio de cita médica',
      mensaje: 'Se recuerda asistir 15 minutos antes del evento.',
      categoria: 'Cita médica',
      destinatarios: 'Todos',
      fecha: '23/03/2026',
    ),
    HistorialNotificacionModel(
      titulo: 'Cambio de horario',
      mensaje: 'La sesión de psicología fue reagendada para las 10:30 AM.',
      categoria: 'Psicólogo',
      destinatarios: '2 usuarios',
      fecha: '22/03/2026',
    ),
  ];

  String _searchText = '';
  String _categoriaSeleccionada = 'General';
  bool _enviarATodos = true;

  List<String> _usuariosSeleccionados = [];

  final List<String> _categorias = const [
    'General',
    'Psicólogo',
    'Inyección',
    'Cita médica',
    'Odontología',
    'Laboratorio',
    'Control general',
    'Vacunación',
    'Terapia',
  ];

  List<UsuarioNotificacionModel> get _filteredUsuarios {
    final usuariosNormales =
        _usuarios.where((u) => u.rol == 'Usuario').toList();

    if (_searchText.trim().isEmpty) return usuariosNormales;

    return usuariosNormales.where((usuario) {
      final text = _searchText.toLowerCase();
      return usuario.nombre.toLowerCase().contains(text) ||
          usuario.correo.toLowerCase().contains(text);
    }).toList();
  }

  int get _usuariosActivos =>
      _usuarios.where((u) => u.rol == 'Usuario' && u.activo).length;

  int get _cantidadSeleccionados => _usuariosSeleccionados.length;

  void _toggleUsuario(String id) {
    setState(() {
      if (_usuariosSeleccionados.contains(id)) {
        _usuariosSeleccionados.remove(id);
      } else {
        _usuariosSeleccionados.add(id);
      }
    });
  }

  void _toggleSeleccionarTodosVisibles() {
    final visiblesActivos = _filteredUsuarios
        .where((u) => u.activo)
        .map((u) => u.id)
        .toList();

    final todosSeleccionados =
        visiblesActivos.every((id) => _usuariosSeleccionados.contains(id));

    setState(() {
      if (todosSeleccionados) {
        _usuariosSeleccionados.removeWhere((id) => visiblesActivos.contains(id));
      } else {
        for (final id in visiblesActivos) {
          if (!_usuariosSeleccionados.contains(id)) {
            _usuariosSeleccionados.add(id);
          }
        }
      }
    });
  }

  void _enviarNotificacion() {
    final titulo = _tituloController.text.trim();
    final mensaje = _mensajeController.text.trim();

    if (titulo.isEmpty || mensaje.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes completar el título y el mensaje'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_enviarATodos && _usuariosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un usuario'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _historial.insert(
        0,
        HistorialNotificacionModel(
          titulo: titulo,
          mensaje: mensaje,
          categoria: _categoriaSeleccionada,
          destinatarios: _enviarATodos
              ? 'Todos'
              : '${_usuariosSeleccionados.length} usuario(s)',
          fecha: '23/03/2026',
        ),
      );

      _tituloController.clear();
      _mensajeController.clear();
      _categoriaSeleccionada = 'General';
      _enviarATodos = true;
      _usuariosSeleccionados.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificación enviada correctamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tituloController.dispose();
    _mensajeController.dispose();
    super.dispose();
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
              child: _NotificacionesHeader(
                onBack: () => Navigator.pop(context),
                onSend: _enviarNotificacion,
                isTablet: isTablet,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(padding, 0, padding, 24),
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    'Notificaciones',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF181A20),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Envía avisos a los usuarios registrados y revisa el historial de envíos.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8B90A0),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ResumenNotificaciones(
                    totalUsuarios: _usuarios.where((u) => u.rol == 'Usuario').length,
                    activos: _usuariosActivos,
                    historial: _historial.length,
                    isTablet: isTablet,
                  ),
                  const SizedBox(height: 24),
                  _ComposerCard(
                    tituloController: _tituloController,
                    mensajeController: _mensajeController,
                    categoriaSeleccionada: _categoriaSeleccionada,
                    categorias: _categorias,
                    enviarATodos: _enviarATodos,
                    cantidadSeleccionados: _cantidadSeleccionados,
                    onCategoriaChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _categoriaSeleccionada = value;
                      });
                    },
                    onToggleEnviarATodos: (value) {
                      setState(() {
                        _enviarATodos = value;
                        if (value) {
                          _usuariosSeleccionados.clear();
                        }
                      });
                    },
                    onSend: _enviarNotificacion,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Destinatarios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF181A20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SearchField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (!_enviarATodos)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _toggleSeleccionarTodosVisibles,
                        icon: const Icon(
                          Icons.done_all_rounded,
                          color: Color(0xFF2D4ECF),
                        ),
                        label: const Text(
                          'Seleccionar visibles',
                          style: TextStyle(
                            color: Color(0xFF2D4ECF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (_filteredUsuarios.isEmpty)
                    const _EmptyUsuariosNotificacionState()
                  else
                    ..._filteredUsuarios.map(
                      (usuario) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _UsuarioSelectableCard(
                          usuario: usuario,
                          seleccionado:
                              _usuariosSeleccionados.contains(usuario.id),
                          bloqueado: _enviarATodos || !usuario.activo,
                          onTap: () {
                            if (_enviarATodos || !usuario.activo) return;
                            _toggleUsuario(usuario.id);
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Historial de notificaciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF181A20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_historial.isEmpty)
                    const _EmptyHistorialState()
                  else
                    ..._historial.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistorialCard(item: item),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isTablet
          ? null
          : FloatingActionButton(
              elevation: 0,
              backgroundColor: const Color(0xFF2D4ECF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              onPressed: _enviarNotificacion,
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
    );
  }
}

class _NotificacionesHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSend;
  final bool isTablet;

  const _NotificacionesHeader({
    required this.onBack,
    required this.onSend,
    required this.isTablet,
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
        isTablet
            ? _PrimaryHeaderButton(
                icon: Icons.send_rounded,
                label: 'Enviar notificación',
                onTap: onSend,
              )
            : _HeaderButton(
                icon: Icons.send_rounded,
                onTap: onSend,
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

class _ResumenNotificaciones extends StatelessWidget {
  final int totalUsuarios;
  final int activos;
  final int historial;
  final bool isTablet;

  const _ResumenNotificaciones({
    required this.totalUsuarios,
    required this.activos,
    required this.historial,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MiniResumenCard(
        title: 'Usuarios',
        value: '$totalUsuarios',
        icon: Icons.people_alt_outlined,
      ),
      _MiniResumenCard(
        title: 'Activos',
        value: '$activos',
        icon: Icons.notifications_active_outlined,
      ),
      _MiniResumenCard(
        title: 'Historial',
        value: '$historial',
        icon: Icons.history_rounded,
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

class _ComposerCard extends StatelessWidget {
  final TextEditingController tituloController;
  final TextEditingController mensajeController;
  final String categoriaSeleccionada;
  final List<String> categorias;
  final bool enviarATodos;
  final int cantidadSeleccionados;
  final ValueChanged<String?> onCategoriaChanged;
  final ValueChanged<bool> onToggleEnviarATodos;
  final VoidCallback onSend;

  const _ComposerCard({
    required this.tituloController,
    required this.mensajeController,
    required this.categoriaSeleccionada,
    required this.categorias,
    required this.enviarATodos,
    required this.cantidadSeleccionados,
    required this.onCategoriaChanged,
    required this.onToggleEnviarATodos,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Redactar notificación',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF181A20),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Puedes enviar un aviso general o dirigirlo a usuarios específicos.',
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF8B90A0),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          const _InputLabel('Título'),
          const SizedBox(height: 8),
          TextField(
            controller: tituloController,
            decoration: _inputDecoration(
              hint: 'Ingresa el título',
              icon: Icons.title_rounded,
            ),
          ),
          const SizedBox(height: 16),
          const _InputLabel('Categoría'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8EBF3)),
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
                onChanged: onCategoriaChanged,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _InputLabel('Mensaje'),
          const SizedBox(height: 8),
          TextField(
            controller: mensajeController,
            maxLines: 4,
            decoration: _inputDecoration(
              hint: 'Escribe el mensaje que recibirán los usuarios',
              icon: Icons.message_outlined,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8EBF3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    enviarATodos
                        ? 'Enviar a todos los usuarios'
                        : 'Enviar solo a seleccionados ($cantidadSeleccionados)',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF181A20),
                    ),
                  ),
                ),
                Switch(
                  value: enviarATodos,
                  activeColor: const Color(0xFF2D4ECF),
                  onChanged: onToggleEnviarATodos,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D4ECF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded),
              label: const Text(
                'Enviar notificación',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
      decoration: _inputDecoration(
        hint: 'Buscar usuarios por nombre o correo',
        icon: Icons.search_rounded,
      ),
    );
  }
}

class _UsuarioSelectableCard extends StatelessWidget {
  final UsuarioNotificacionModel usuario;
  final bool seleccionado;
  final bool bloqueado;
  final VoidCallback onTap;

  const _UsuarioSelectableCard({
    required this.usuario,
    required this.seleccionado,
    required this.bloqueado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final estadoColor =
        usuario.activo ? const Color(0xFF2D4ECF) : const Color(0xFF9EA4B5);

    return Opacity(
      opacity: bloqueado ? 0.72 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: seleccionado
                    ? const Color(0xFF2D4ECF)
                    : const Color(0xFFE8EBF3),
                width: seleccionado ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    seleccionado
                        ? Icons.check_circle_rounded
                        : Icons.person_outline_rounded,
                    color: const Color(0xFF2D4ECF),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario.nombre,
                        style: const TextStyle(
                          fontSize: 16.2,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF181A20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        usuario.correo,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF8B90A0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoBadge(
                            label: usuario.rol,
                            color: const Color(0xFF2D4ECF),
                            background: const Color(0xFFEAF0FF),
                          ),
                          _InfoBadge(
                            label: usuario.activo ? 'Activo' : 'Inactivo',
                            color: estadoColor,
                            background: usuario.activo
                                ? const Color(0xFFEAF0FF)
                                : const Color(0xFFF0F2F7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: seleccionado,
                  onChanged: bloqueado ? null : (_) => onTap(),
                  activeColor: const Color(0xFF2D4ECF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistorialCard extends StatelessWidget {
  final HistorialNotificacionModel item;

  const _HistorialCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFF2D4ECF),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.titulo,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF181A20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.mensaje,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF8B90A0),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoBadge(
                label: item.categoria,
                color: const Color(0xFF2D4ECF),
                background: const Color(0xFFEAF0FF),
              ),
              _InfoBadge(
                label: item.destinatarios,
                color: const Color(0xFF4D5875),
                background: const Color(0xFFF0F2F7),
              ),
              _InfoBadge(
                label: item.fecha,
                color: const Color(0xFF4D5875),
                background: const Color(0xFFF0F2F7),
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

class _EmptyUsuariosNotificacionState extends StatelessWidget {
  const _EmptyUsuariosNotificacionState();

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
            Icons.person_search_outlined,
            size: 54,
            color: Color(0xFF2D4ECF),
          ),
          SizedBox(height: 12),
          Text(
            'No se encontraron usuarios',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF181A20),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Intenta con otro criterio de búsqueda.',
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

class _EmptyHistorialState extends StatelessWidget {
  const _EmptyHistorialState();

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
            Icons.history_toggle_off_rounded,
            size: 54,
            color: Color(0xFF2D4ECF),
          ),
          SizedBox(height: 12),
          Text(
            'No hay historial todavía',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF181A20),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Cuando envíes una notificación aparecerá aquí.',
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
    fillColor: Colors.white,
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

class UsuarioNotificacionModel {
  final String id;
  final String nombre;
  final String correo;
  final String rol;
  final bool activo;

  UsuarioNotificacionModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.activo,
  });
}

class HistorialNotificacionModel {
  final String titulo;
  final String mensaje;
  final String categoria;
  final String destinatarios;
  final String fecha;

  HistorialNotificacionModel({
    required this.titulo,
    required this.mensaje,
    required this.categoria,
    required this.destinatarios,
    required this.fecha,
  });
}