import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserHomePage extends ConsumerWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final width = size.width;
    final isTablet = width >= 700;

    final horizontalPadding = width * 0.06;
    final crossAxisCount = isTablet ? 3 : (width < 360 ? 1 : 2);
    final childAspectRatio = isTablet ? 1.08 : 0.86;
    final authState = ref.watch(authControllerProvider);
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
                child: _UserHeader(
                  width: width,
                  userName: authState.name,
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
                child: const _UserOverviewSection(),
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
                child: const _UserSectionTitle(
                  title: 'Mis módulos',
                  subtitle: 'Gestiona tus eventos y recordatorios',
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate(
                  const [
                    _UserModuleCard(
                      title: 'Mis eventos',
                      subtitle: 'Consulta, edita y filtra tus eventos',
                      icon: Icons.event_note_outlined,
                      color: Color(0xFF2D4ECF),
                      route: '/mis-eventos',
                    ),
                    _UserModuleCard(
                      title: 'Calendario',
                      subtitle: 'Visualiza tus fechas programadas',
                      icon: Icons.calendar_month_outlined,
                      color: Color(0xFF4D6EF0),
                      route: '/mis-eventos',
                    ),
                    _UserModuleCard(
                      title: 'Recordatorios',
                      subtitle: 'Eventos próximos y alertas',
                      icon: Icons.notifications_none_rounded,
                      color: Color(0xFF3557D6),
                      route: '/mis-eventos',
                    ),
                    _UserModuleCard(
                      title: 'Categorías',
                      subtitle: 'Consulta por tipo de evento',
                      icon: Icons.category_outlined,
                      color: Color(0xFF2D4ECF),
                      route: '/mis-eventos',
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
                child: const _UserSectionTitle(
                  title: 'Acciones rápidas',
                  subtitle: 'Lo más usado por el usuario',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: const _UserQuickActionsRow(),
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
                child: const _UserSectionTitle(
                  title: 'Actividad reciente',
                  subtitle: 'Resumen de tus últimos eventos',
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
                child: const _UserRecentActivityCard(),
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
        onPressed: () {
          context.push('/mis-eventos');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final double width;
  final String? userName;

  const _UserHeader({
    required this.width,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = width < 360;
    final displayName =
        userName?.trim().isNotEmpty == true ? userName!.trim() : 'Usuario';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -18,
            right: -12,
            child: _UserDecorBubble(
              size: isSmall ? 62 : 74,
              color: const Color(0xFF3557D6),
              icon: Icons.event_note_outlined,
            ),
          ),
          Positioned(
            top: 38,
            right: 54,
            child: _UserDecorBubble(
              size: isSmall ? 34 : 40,
              color: const Color(0xFF4D6EF0),
              icon: Icons.notifications_none_rounded,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: isSmall ? 52 : 58,
                    height: isSmall ? 52 : 58,
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
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFF2D4ECF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Bienvenido $displayName',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF181A20),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gestiona tus eventos, recordatorios y próximas actividades desde un solo lugar.',
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: Color(0xFF8B90A0),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserOverviewSection extends StatelessWidget {
  const _UserOverviewSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        if (isWide) {
          return Row(
            children: const [
              Expanded(
                child: _UserOverviewCard(
                  title: 'Mis eventos',
                  value: '12',
                  subtitle: 'Registrados',
                  icon: Icons.event_note_outlined,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _UserOverviewCard(
                  title: 'Activos',
                  value: '8',
                  subtitle: 'Actualmente visibles',
                  icon: Icons.verified_outlined,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _UserOverviewCard(
                  title: 'Próximos',
                  value: '3',
                  subtitle: 'Pendientes esta semana',
                  icon: Icons.notifications_active_outlined,
                ),
              ),
            ],
          );
        }

        return Column(
          children: const [
            _UserOverviewCard(
              title: 'Mis eventos',
              value: '12',
              subtitle: 'Registrados',
              icon: Icons.event_note_outlined,
            ),
            SizedBox(height: 12),
            _UserOverviewCard(
              title: 'Activos',
              value: '8',
              subtitle: 'Actualmente visibles',
              icon: Icons.verified_outlined,
            ),
            SizedBox(height: 12),
            _UserOverviewCard(
              title: 'Próximos',
              value: '3',
              subtitle: 'Pendientes esta semana',
              icon: Icons.notifications_active_outlined,
            ),
          ],
        );
      },
    );
  }
}

class _UserOverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _UserOverviewCard({
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

class _UserModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _UserModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push(route),
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
                const SizedBox(height: 2),
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

class _UserQuickActionsRow extends StatelessWidget {
  const _UserQuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        _UserQuickActionChip(
          icon: Icons.add_circle_outline_rounded,
          label: 'Nuevo evento',
        ),
        _UserQuickActionChip(
          icon: Icons.filter_alt_outlined,
          label: 'Filtrar',
        ),
        _UserQuickActionChip(
          icon: Icons.calendar_today_outlined,
          label: 'Ver agenda',
        ),
        _UserQuickActionChip(
          icon: Icons.notifications_none_rounded,
          label: 'Recordatorios',
        ),
      ],
    );
  }
}

class AdminDashboardStats {
  final int totalUsers;
  final int totalEvents;
  final int pendingNotifications;

  const AdminDashboardStats({
    required this.totalUsers,
    required this.totalEvents,
    required this.pendingNotifications,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalUsers: int.tryParse('${json['totalUsers'] ?? 0}') ?? 0,
      totalEvents: int.tryParse('${json['totalEvents'] ?? 0}') ?? 0,
      pendingNotifications:
          int.tryParse('${json['pendingNotifications'] ?? 0}') ?? 0,
    );
  }
}

class _UserQuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _UserQuickActionChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
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

class _UserRecentActivityCard extends StatelessWidget {
  const _UserRecentActivityCard();

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
          _UserActivityTile(
            icon: Icons.event_note_outlined,
            title: 'Evento creado',
            subtitle: 'Reunión registrada para el viernes',
            time: 'Hace 15 min',
          ),
          Divider(height: 26, color: Color(0xFFE7EAF3)),
          _UserActivityTile(
            icon: Icons.edit_calendar_outlined,
            title: 'Evento actualizado',
            subtitle: 'Se modificó la hora de un evento',
            time: 'Hace 40 min',
          ),
          Divider(height: 26, color: Color(0xFFE7EAF3)),
          _UserActivityTile(
            icon: Icons.notifications_none_rounded,
            title: 'Recordatorio próximo',
            subtitle: 'Tienes un evento cercano en 1 día',
            time: 'Hoy',
          ),
        ],
      ),
    );
  }
}

class _UserActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _UserActivityTile({
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

class _UserSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _UserSectionTitle({
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

class _UserDecorBubble extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;

  const _UserDecorBubble({
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
