import 'package:event_app/app/router.dart' as app_router;
import 'package:event_app/core/services/push_notification_service.dart';
import 'package:event_app/core/theme/app_theme.dart';
import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _pushInitialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPushNotifications();
    });
  }

  Future<void> _initPushNotifications() async {
    if (_pushInitialized) return;
    _pushInitialized = true;

    await PushNotificationService.instance.init(
      onNotificationTap: (data) async {
        debugPrint('📲 Push tocada con data: $data');

        AuthState authState = ref.read(authControllerProvider);

        int attempts = 0;

        while (authState.isCheckingStoredSession && attempts < 10) {
          await Future.delayed(const Duration(milliseconds: 200));
          authState = ref.read(authControllerProvider);
          attempts++;
        }

        final router = ref.read(app_router.appRouterProvider);

        if (!authState.isAuthenticated && !authState.isSessionLocked) {
          debugPrint('⛔ Push tocada, pero no hay sesión iniciada');
          return;
        }

        if (authState.isSessionLocked) {
          debugPrint('🔒 Sesión bloqueada, enviando a desbloqueo');
          router.go('/unlock');
          return;
        }

        final type = data['type']?.toString();

        if (type == 'event') {
          if (authState.role == UserRole.admin) {
            router.go('/eventos');
          } else {
            router.go('/mis-eventos');
          }
          return;
        }

        if (type == 'notification') {
          if (authState.role == UserRole.admin) {
            router.go('/notificaciones');
          } else {
            router.go('/home-user');
          }
          return;
        }

        if (authState.role == UserRole.admin) {
          router.go('/home-admin');
        } else {
          router.go('/home-user');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(app_router.appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Agenda Eventos',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      locale: const Locale('es', 'ES'),
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
