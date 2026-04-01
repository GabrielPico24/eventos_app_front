import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionUnlockPage extends ConsumerWidget {
  const SessionUnlockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 80,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Su sesión ha expirado',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Desbloquee con Face ID o huella para continuar.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.isRefreshingSession
                        ? null
                        : () async {
                            final ok = await ref
                                .read(authControllerProvider.notifier)
                                .unlockSessionWithBiometrics();

                            if (!ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No se pudo renovar la sesión',
                                  ),
                                ),
                              );
                            }
                          },
                    child: Text(
                      authState.isRefreshingSession
                          ? 'Verificando...'
                          : 'Desbloquear',
                    ),
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