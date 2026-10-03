import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_router.dart';
import 'app_theme.dart';
import '../core/constants/app_config.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../shared/providers/app_state.dart';

class FeelItApp extends ConsumerWidget {
  const FeelItApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'FEEL-IT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.hasSupabaseConfig) return const AppShell();

    final client = Supabase.instance.client;
    return StreamBuilder<Session?>(
      stream: client.auth.onAuthStateChange.map((state) => state.session),
      initialData: client.auth.currentSession,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data == null ? const AuthScreen() : const AppShell();
      },
    );
  }
}
