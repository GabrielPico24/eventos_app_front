import 'package:event_app/features/admin/presentation/pages/admin_home_page.dart';
import 'package:event_app/features/auth/presentation/pages/biometric_unlock_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:event_app/features/auth/presentation/pages/login_page.dart';

class AppSessionGate extends ConsumerStatefulWidget {
  const AppSessionGate({super.key});

  @override
  ConsumerState<AppSessionGate> createState() => _AppSessionGateState();
}

class _AppSessionGateState extends ConsumerState<AppSessionGate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authControllerProvider.notifier).checkStoredSessionOnAppStart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    if (authState.isCheckingStoredSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authState.isSessionLocked) {
      return const BiometricUnlockPage();
    }

    if (!authState.isAuthenticated) {
      return const LoginPage();
    }

    if (authState.role == UserRole.admin) {
      return const AdminHomePage();
    }

    return const LoginPage();
  }
}