import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/services/supabase_auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final configured = AppConfig.hasSupabaseConfig;
    final email =
        configured ? Supabase.instance.client.auth.currentUser?.email : null;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Rider profile',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        GlassCard(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(email ?? 'Rider account'),
            subtitle: Text(configured
                ? 'Supabase authenticated session'
                : 'Supabase is not configured'),
          ),
        ),
        const SizedBox(height: 12),
        const GlassCard(
          child: ListTile(
            leading: Icon(Icons.security),
            title: Text('Supabase session'),
            subtitle: Text('Session lifecycle is managed by Supabase Auth.'),
          ),
        ),
        if (configured) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              try {
                await SupabaseAuthService().signOut();
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Could not sign out. Try again.')),
                  );
                }
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ],
    );
  }
}
