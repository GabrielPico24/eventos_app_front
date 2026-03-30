import 'package:event_app/features/admin/presentation/pages/admin_home_page.dart';
import 'package:event_app/features/admin/presentation/pages/eventos_page.dart';
import 'package:event_app/features/admin/presentation/pages/notificaciones_page.dart';
import 'package:event_app/features/admin/presentation/pages/usuarios_page.dart';
import 'package:event_app/features/auth/presentation/pages/login_page.dart';
import 'package:event_app/features/categories/presentation/pages/categories_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home-admin',
        builder: (context, state) => const AdminHomePage(),
      ),
      GoRoute(
        path: '/usuarios',
        builder: (context, state) => const UsuariosPage(),
      ),
      GoRoute(
        path: '/eventos',
        builder: (context, state) => const EventosPage(),
      ),
      GoRoute(
        path: '/notificaciones',
        builder: (context, state) => const NotificacionesPage(),
      ),
      GoRoute(
  path: '/categorias',
  builder: (context, state) => const CategoriesPage(),
),
      GoRoute(
        path: '/home-user',
        builder: (context, state) => const _HomeUserPage(),
      ),
    ],
  );
});

class _HomeUserPage extends StatelessWidget {
  const _HomeUserPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home Usuario')),
    );
  }
}
