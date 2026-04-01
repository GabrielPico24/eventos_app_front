import 'package:event_app/app/router.dart';
import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:event_app/features/auth/presentation/pages/biometric_unlock_page.dart';
import 'package:event_app/features/auth/presentation/pages/session_unlock_page.dart';
import 'package:event_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _sessionChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_sessionChecked) {
      _sessionChecked = true;

      Future.microtask(() {
        ref.read(authControllerProvider.notifier).checkStoredSessionOnAppStart();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final authState = ref.watch(authControllerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Agenda Eventos',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        final appChild = child ?? const SizedBox.shrink();

        if (authState.isCheckingStoredSession) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authState.isSessionLocked) {
          return Stack(
            children: [
              appChild,
              const BiometricUnlockPage(),
            ],
          );
        }

        return appChild;
      },
    );
  }
}