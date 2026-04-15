import 'package:event_app/features/admin/presentation/providers/admin_dashboard_provider.dart';
import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    await showDialog(
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
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFF2D4ECF),
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Cerrar sesión',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF181A20),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '¿Quieres cerrar sesión?',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                          backgroundColor: const Color(0xFF2D4ECF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await ref
                              .read(authControllerProvider.notifier)
                              .logout();

                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                        child: const Text(
                          'Aceptar',
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
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final media = MediaQuery.of(context);
    final size = media.size;
    final width = size.width;
    final isTablet = width >= 700;

    final horizontalPadding = width * 0.06;
    final crossAxisCount = isTablet ? 3 : (width < 360 ? 1 : 2);
    final childAspectRatio = isTablet ? 1.05 : 0.78;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  18,
                  horizontalPadding,
                  8,
                ),
                child: _AdminHeader(
  width: width,
  onLogoutTap: () => _showLogoutDialog(context, ref),
  userName: authState.name ?? 'Administrador',
),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: const SizedBox(height: 12),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: const _OverviewSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  26,
                  horizontalPadding,
                  14,
                ),
                child: const _SectionTitle(
                  title: 'Módulos principales',
                  subtitle: 'Gestiona todas las funciones administrativas',
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate(
                  const [
                    _AdminModuleCard(
                      title: 'Usuarios',
                      subtitle: 'Crear, editar y eliminar usuarios',
                      icon: Icons.people_alt_outlined,
                      color: Color(0xFF2D4ECF),
                    ),
                    _AdminModuleCard(
                      title: 'Eventos',
                      subtitle:
                          'Consulta y supervisa todos los eventos registrados',
                      icon: Icons.event_note_outlined,
                      color: Color(0xFF4D6EF0),
                    ),
                    _AdminModuleCard(
                      title: 'Categorías',
                      subtitle: 'Tipos de eventos y servicios',
                      icon: Icons.category_outlined,
                      color: Color(0xFF3557D6),
                    ),
                    _AdminModuleCard(
                      title: 'Notificaciones',
                      subtitle: 'Enviar avisos a usuarios registrados',
                      icon: Icons.notifications_none_rounded,
                      color: Color(0xFF2D4ECF),
                    ),
                    _AdminModuleCard(
                      title: 'Calendario',
                      subtitle: 'Visualiza agenda diaria y mensual',
                      icon: Icons.calendar_month_outlined,
                      color: Color(0xFF4D6EF0),
                    ),
                    _AdminModuleCard(
                      title: 'Reportes',
                      subtitle: 'Resumen de actividad y asistencia',
                      icon: Icons.bar_chart_rounded,
                      color: Color(0xFF3557D6),
                    ),
                    _AdminModuleCard(
                      title: 'Solicitudes',
                      subtitle: 'Aprobaciones o cambios pendientes',
                      icon: Icons.assignment_late_outlined,
                      color: Color(0xFF2D4ECF),
                    ),
                    _AdminModuleCard(
                      title: 'Configuración',
                      subtitle: 'Parámetros generales de la app',
                      icon: Icons.settings_outlined,
                      color: Color(0xFF4D6EF0),
                    ),
                  ],
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: childAspectRatio,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  28,
                  horizontalPadding,
                  14,
                ),
                child: const _SectionTitle(
                  title: 'Acciones rápidas',
                  subtitle: 'Lo más usado por el administrador',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: const _QuickActionsRow(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  28,
                  horizontalPadding,
                  14,
                ),
                child: const _SectionTitle(
                  title: 'Actividad reciente',
                  subtitle: 'Últimos movimientos del sistema',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  28,
                ),
                child: const _RecentActivityCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final double width;
  final VoidCallback onLogoutTap;
  final String userName;

  const _AdminHeader({
    required this.width,
    required this.onLogoutTap,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = width < 360;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE7EAF3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isSmall ? 56 : 62,
                height: isSmall ? 56 : 62,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D4ECF).withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Color(0xFF2D4ECF),
                  size: 30,
                ),
              ),
              const Spacer(),
              _HeaderActionButton(
                icon: Icons.logout_rounded,
                onTap: onLogoutTap,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Panel $userName',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF181A20),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Administra usuarios, eventos, categorías, notificaciones y reportes desde un solo lugar.',
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.45,
              color: Color(0xFF8B90A0),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE7EAF3),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D4ECF).withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2D4ECF),
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _OverviewSection extends ConsumerWidget {
  const _OverviewSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return statsAsync.when(
      loading: () => const Column(
        children: [
          _OverviewCard(
            title: 'Usuarios',
            value: '...',
            subtitle: 'Cargando',
            icon: Icons.people_outline_rounded,
          ),
          SizedBox(height: 12),
          _OverviewCard(
            title: 'Eventos',
            value: '...',
            subtitle: 'Cargando',
            icon: Icons.event_available_outlined,
          ),
          SizedBox(height: 12),
          _OverviewCard(
            title: 'Avisos',
            value: '...',
            subtitle: 'Cargando',
            icon: Icons.campaign_outlined,
          ),
        ],
      ),
      error: (error, stack) => Column(
        children: [
          _OverviewCard(
            title: 'Usuarios',
            value: '0',
            subtitle: 'Error al cargar',
            icon: Icons.people_outline_rounded,
          ),
          const SizedBox(height: 12),
          _OverviewCard(
            title: 'Eventos',
            value: '0',
            subtitle: 'Error al cargar',
            icon: Icons.event_available_outlined,
          ),
          const SizedBox(height: 12),
          _OverviewCard(
            title: 'Avisos',
            value: '0',
            subtitle: 'Error al cargar',
            icon: Icons.campaign_outlined,
          ),
        ],
      ),
      data: (stats) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            final cards = [
              _OverviewCard(
                title: 'Usuarios',
                value: stats.totalUsers.toString(),
                subtitle: 'Registrados',
                icon: Icons.people_outline_rounded,
              ),
              _OverviewCard(
                title: 'Eventos',
                value: stats.totalEvents.toString(),
                subtitle: 'Activos este mes',
                icon: Icons.event_available_outlined,
              ),
              _OverviewCard(
                title: 'Avisos',
                value: stats.pendingNotifications.toString(),
                subtitle: 'Pendientes de enviar',
                icon: Icons.campaign_outlined,
              ),
            ];

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[1]),
                  const SizedBox(width: 12),
                  Expanded(child: cards[2]),
                ],
              );
            }

            return Column(
              children: [
                cards[0],
                const SizedBox(height: 12),
                cards[1],
                const SizedBox(height: 12),
                cards[2],
              ],
            );
          },
        );
      },
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE7EAF3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2D4ECF),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF181A20),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF181A20),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF8B90A0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _AdminModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          if (title == 'Usuarios') {
            context.push('/usuarios');
            return;
          }

          if (title == 'Eventos') {
            context.push('/eventos');
            return;
          }

          if (title == 'Categorías') {
            context.push('/categorias');
            return;
          }

          if (title == 'Notificaciones') {
            context.push('/notificaciones');
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Abrir módulo: $title'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE7EAF3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF181A20),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Color(0xFF8B90A0),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D4ECF),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Color(0xFF2D4ECF),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        _QuickActionChip(
          icon: Icons.person_add_alt_1_rounded,
          label: 'Nuevo usuario',
        ),
        _QuickActionChip(
          icon: Icons.event_available_rounded,
          label: 'Nuevo evento',
        ),
        _QuickActionChip(
          icon: Icons.send_rounded,
          label: 'Enviar aviso',
        ),
        _QuickActionChip(
          icon: Icons.summarize_outlined,
          label: 'Ver reportes',
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickActionChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(label),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE7EAF3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF2D4ECF), size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF181A20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7EAF3)),
      ),
      child: const Column(
        children: [
          _ActivityTile(
            icon: Icons.people_outline_rounded,
            title: 'Usuario registrado',
            subtitle: 'Se creó un nuevo usuario normal',
            time: 'Hace 10 min',
          ),
          Divider(height: 26, color: Color(0xFFE7EAF3)),
          _ActivityTile(
            icon: Icons.event_note_outlined,
            title: 'Evento creado',
            subtitle: 'Cita médica programada para mañana',
            time: 'Hace 22 min',
          ),
          Divider(height: 26, color: Color(0xFFE7EAF3)),
          _ActivityTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notificación enviada',
            subtitle: 'Aviso general a usuarios registrados',
            time: 'Hace 1 hora',
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2D4ECF),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF181A20),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8B90A0),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          time,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF8B90A0),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF181A20),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF8B90A0),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _DecorBubble extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;

  const _DecorBubble({
    required this.size,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.98,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Center(
          child: Icon(
            icon,
            size: size * 0.40,
            color: Colors.white.withOpacity(0.34),
          ),
        ),
      ),
    );
  }
}
