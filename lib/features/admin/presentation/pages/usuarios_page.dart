import 'package:event_app/features/auth/presentation/controller/users_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsuariosPage extends ConsumerStatefulWidget {
  const UsuariosPage({super.key});

  @override
  ConsumerState<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends ConsumerState<UsuariosPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(usersControllerProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UsuarioModel> _mapUsersToUi(List users) {
    return users
        .map(
          (u) => UsuarioModel(
            id: u.id,
            nombre: u.name,
            correo: u.email,
            rol: u.role == 'admin' ? 'Administrador' : 'Usuario',
            activo: u.isActive,
          ),
        )
        .toList();
  }

  List<UsuarioModel> _filteredUsuarios(List<UsuarioModel> usuarios) {
    if (_searchText.trim().isEmpty) return usuarios;

    return usuarios.where((usuario) {
      final text = _searchText.toLowerCase();
      return usuario.nombre.toLowerCase().contains(text) ||
          usuario.correo.toLowerCase().contains(text) ||
          usuario.rol.toLowerCase().contains(text);
    }).toList();
  }

  void _openUsuarioDialog({UsuarioModel? usuario}) {
    final isEdit = usuario != null;

    final nombreController =
        TextEditingController(text: isEdit ? usuario.nombre : '');
    final correoController =
        TextEditingController(text: isEdit ? usuario.correo : '');
    final passwordController = TextEditingController();
    String rolSeleccionado = isEdit ? usuario.rol : 'Usuario';
    bool activo = isEdit ? usuario.activo : true;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final bottomInset = MediaQuery.of(modalContext).viewInsets.bottom;
            final usersState = ref.watch(usersControllerProvider);

            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          const SizedBox(height: 20),
                          Text(
                            isEdit ? 'Editar usuario' : 'Nuevo usuario',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF181A20),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isEdit
                                ? 'Modifica la información del usuario seleccionado.'
                                : 'Completa la información para registrar un nuevo usuario.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8B90A0),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const _InputLabel('Nombre completo'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: nombreController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                              hint: 'Ingresa el nombre',
                              icon: Icons.person_outline_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es obligatorio';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const _InputLabel('Correo electrónico'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: correoController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              hint: 'Ingresa el correo',
                              icon: Icons.mail_outline_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El correo es obligatorio';
                              }
                              if (!value.contains('@')) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const _InputLabel('Contraseña'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: _inputDecoration(
                              hint: isEdit
                                  ? 'Dejar vacío para no cambiar'
                                  : 'Ingresa la contraseña',
                              icon: Icons.lock_outline_rounded,
                            ),
                            validator: (value) {
                              if (!isEdit &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'La contraseña es obligatoria';
                              }
                              if (!isEdit && value!.trim().length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const _InputLabel('Rol'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FC),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE8EBF3),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: rolSeleccionado,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF2D4ECF),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Administrador',
                                    child: Text('Administrador'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Usuario',
                                    child: Text('Usuario'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value == null) return;
                                  setModalState(() {
                                    rolSeleccionado = value;
                                  });
                                },
                              ),
                            ),
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
                                    'Usuario activo',
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
                              onPressed: (usersState.isCreating ||
                                      usersState.isUpdating)
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

                                      final messenger =
                                          ScaffoldMessenger.of(this.context);
                                      final navigator =
                                          Navigator.of(modalContext);

                                      try {
                                        if (isEdit) {
                                          await ref
                                              .read(usersControllerProvider
                                                  .notifier)
                                              .updateUser(
                                                id: usuario.id,
                                                name: nombreController.text
                                                    .trim(),
                                                email: correoController.text
                                                    .trim(),
                                                password: passwordController
                                                    .text
                                                    .trim(),
                                                role: rolSeleccionado ==
                                                        'Administrador'
                                                    ? 'admin'
                                                    : 'user',
                                                isActive: activo,
                                              );

                                          if (!mounted) return;

                                          navigator.pop();

                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Usuario editado correctamente'),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                          return;
                                        }

                                        await ref
                                            .read(usersControllerProvider
                                                .notifier)
                                            .createUser(
                                              name:
                                                  nombreController.text.trim(),
                                              email:
                                                  correoController.text.trim(),
                                              password: passwordController.text
                                                  .trim(),
                                              role: rolSeleccionado ==
                                                      'Administrador'
                                                  ? 'admin'
                                                  : 'user',
                                              isActive: activo,
                                            );

                                        if (!mounted) return;

                                        navigator.pop();

                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Usuario creado correctamente'),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      } catch (e) {
                                        if (!mounted) return;

                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              e.toString().replaceFirst(
                                                  'Exception: ', ''),
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                              child: (usersState.isCreating ||
                                      usersState.isUpdating)
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isEdit
                                          ? 'Guardar cambios'
                                          : 'Crear usuario',
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
              ),
            );
          },
        );
      },
    );
  }

  void _deleteUsuario(UsuarioModel usuario) {
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
              const Text(
                'Eliminar usuario',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF181A20),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '¿Deseas eliminar a ${usuario.nombre}?\nEsta acción no se puede deshacer.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8B90A0),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
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

                            await ref
                                .read(usersControllerProvider.notifier)
                                .deleteUser(id: usuario.id);

                            if (!mounted) return;

                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${usuario.nombre} eliminado correctamente',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;

                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
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

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersControllerProvider);
    final usuarios = _mapUsersToUi(usersState.users);
    final usuariosFiltrados = _filteredUsuarios(usuarios);

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
              child: _UsuariosHeader(
                onBack: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF2D4ECF),
                onRefresh: () async {
                  await ref.read(usersControllerProvider.notifier).loadUsers();
                },
                child: ListView(
                  padding: EdgeInsets.fromLTRB(padding, 0, padding, 24),
                  children: [
                    const SizedBox(height: 6),
                    const Text(
                      'Usuarios',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF181A20),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Administra los usuarios registrados dentro de la aplicación.',
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
                    _ResumenUsuarios(
                      total: usuarios.length,
                      activos: usuarios.where((e) => e.activo).length,
                      administradores: usuarios
                          .where((e) => e.rol == 'Administrador')
                          .length,
                      isTablet: isTablet,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Listado de usuarios',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF181A20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (usersState.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2D4ECF),
                          ),
                        ),
                      )
                    else if (usersState.errorMessage != null &&
                        usersState.users.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FC),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE8EBF3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 54,
                              color: Color(0xFF2D4ECF),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No se pudieron cargar los usuarios',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF181A20),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              usersState.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF8B90A0),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D4ECF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                ref
                                    .read(usersControllerProvider.notifier)
                                    .loadUsers();
                              },
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    else if (usuariosFiltrados.isEmpty)
                      const _EmptyUsuariosState()
                    else
                      ...usuariosFiltrados.map(
                        (usuario) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _UsuarioCard(
                            usuario: usuario,
                            onEdit: () => _openUsuarioDialog(usuario: usuario),
                            onDelete: () => _deleteUsuario(usuario),
                          ),
                        ),
                      ),
                  ],
                ),
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
              onPressed: () => _openUsuarioDialog(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
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

class _UsuariosHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _UsuariosHeader({
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
        const Spacer(),
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
        hintText: 'Buscar por nombre, correo o rol',
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

class _ResumenUsuarios extends StatelessWidget {
  final int total;
  final int activos;
  final int administradores;
  final bool isTablet;

  const _ResumenUsuarios({
    required this.total,
    required this.activos,
    required this.administradores,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MiniResumenCard(
        title: 'Total',
        value: '$total',
        icon: Icons.people_alt_outlined,
      ),
      _MiniResumenCard(
        title: 'Activos',
        value: '$activos',
        icon: Icons.verified_user_outlined,
      ),
      _MiniResumenCard(
        title: 'Admins',
        value: '$administradores',
        icon: Icons.admin_panel_settings_outlined,
      ),
    ];

    if (isTablet) {
      return Row(
        children: cards
            .asMap()
            .entries
            .map(
              (entry) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: entry.key != cards.length - 1 ? 10 : 0,
                  ),
                  child: entry.value,
                ),
              ),
            )
            .toList(),
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

class _UsuarioCard extends StatelessWidget {
  final UsuarioModel usuario;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UsuarioCard({
    required this.usuario,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final estadoColor =
        usuario.activo ? const Color(0xFF2D4ECF) : const Color(0xFF9EA4B5);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EBF3)),
      ),
      child: Column(
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
                  Icons.person_outline_rounded,
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
                      usuario.nombre,
                      style: const TextStyle(
                        fontSize: 16.5,
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
          Row(
            children: [
              _InfoBadge(
                label: usuario.rol,
                color: const Color(0xFF2D4ECF),
                background: const Color(0xFFEAF0FF),
              ),
              const SizedBox(width: 8),
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

class _EmptyUsuariosState extends StatelessWidget {
  const _EmptyUsuariosState();

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
            'Intenta con otro criterio de búsqueda o crea un nuevo usuario.',
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

class UsuarioModel {
  final String id;
  final String nombre;
  final String correo;
  final String rol;
  final bool activo;

  UsuarioModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.activo,
  });
}
