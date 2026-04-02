import 'package:event_app/features/admin/presentation/pages/admin_home_page.dart';
import 'package:event_app/features/admin/presentation/pages/eventos_admin_page.dart';
import 'package:event_app/features/admin/presentation/pages/notificaciones_page.dart';
import 'package:event_app/features/admin/presentation/pages/usuarios_page.dart';
import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:event_app/features/auth/presentation/pages/biometric_unlock_page.dart';
import 'package:event_app/features/auth/presentation/pages/login_page.dart';
import 'package:event_app/features/categories/presentation/pages/categories_page.dart';
import 'package:event_app/features/events/presentation/pages/my_events_page.dart';
import 'package:event_app/features/user/presentation/pages/user_home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final location = state.matchedLocation;

      // Mientras revisa sesión al iniciar, no redirigir aún
      if (authState.isCheckingStoredSession) {
        return null;
      }

      // Si la sesión está bloqueada por biometría
      if (authState.isSessionLocked) {
        if (location != '/unlock') {
          return '/unlock';
        }
        return null;
      }

      // Si no está autenticado -> login
      if (!authState.isAuthenticated) {
        if (location != '/login') {
          return '/login';
        }
        return null;
      }

      // Si ya está autenticado y está en login o unlock, mandarlo a su home
      if (location == '/login' || location == '/unlock') {
        if (authState.role == UserRole.admin) {
          return '/home-admin';
        } else {
          return '/home-user';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/unlock',
        builder: (context, state) => const BiometricUnlockPage(),
      ),

      // ADMIN
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
        builder: (context, state) => const EventosAdminPage(),
      ),
      GoRoute(
        path: '/notificaciones',
        builder: (context, state) => const NotificacionesPage(),
      ),
      GoRoute(
        path: '/categorias',
        builder: (context, state) => const CategoriesPage(),
      ),

      // USER
      GoRoute(
        path: '/home-user',
        builder: (context, state) => const UserHomePage(),
      ),
      GoRoute(
        path: '/mis-eventos',
        builder: (context, state) => const MyEventsPage(),
      ),
    ],
  );
});