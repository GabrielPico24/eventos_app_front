import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: _AdminHeader(width: width),
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
                      subtitle: 'Citas, inyecciones, psicología y más',
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
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: const Color(0xFF2D4ECF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Aquí puedes abrir un formulario para crear un evento'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final double width;

  const _AdminHeader({required this.width});

  @override
  Widget build(BuildContext context) {
    final isSmall = width < 360;

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
            child: _DecorBubble(
              size: isSmall ? 62 : 74,
              color: const Color(0xFF3557D6),
              icon: Icons.calendar_month_outlined,
            ),
          ),
          Positioned(
            top: 38,
            right: 54,
            child: _DecorBubble(
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
                      Icons.admin_panel_settings_outlined,
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
              const Text(
                'Panel Administrador',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF181A20),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Administra usuarios, eventos, categorías, notificaciones y reportes desde un solo lugar.',
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

class _OverviewSection extends StatelessWidget {
  const _OverviewSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        if (isWide) {
          return Row(
            children: const [
              Expanded(
                child: _OverviewCard(
                  title: 'Usuarios',
                  value: '128',
                  subtitle: 'Registrados',
                  icon: Icons.people_outline_rounded,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _OverviewCard(
                  title: 'Eventos',
                  value: '46',
                  subtitle: 'Activos este mes',
                  icon: Icons.event_available_outlined,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _OverviewCard(
                  title: 'Avisos',
                  value: '12',
                  subtitle: 'Pendientes de enviar',
                  icon: Icons.campaign_outlined,
                ),
              ),
            ],
          );
        }

        return Column(
          children: const [
            _OverviewCard(
              title: 'Usuarios',
              value: '128',
              subtitle: 'Registrados',
              icon: Icons.people_outline_rounded,
            ),
            SizedBox(height: 12),
            _OverviewCard(
              title: 'Eventos',
              value: '46',
              subtitle: 'Activos este mes',
              icon: Icons.event_available_outlined,
            ),
            SizedBox(height: 12),
            _OverviewCard(
              title: 'Avisos',
              value: '12',
              subtitle: 'Pendientes de enviar',
              icon: Icons.campaign_outlined,
            ),
          ],
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
