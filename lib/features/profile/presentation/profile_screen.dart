import 'package:flutter/material.dart';

import '../../../core/widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Rider profile', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        const GlassCard(
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Traveler account'),
            subtitle: Text('Auth, preferences and rider progress'),
          ),
        ),
        const SizedBox(height: 12),
        const GlassCard(
          child: ListTile(
            leading: Icon(Icons.security),
            title: Text('Secure session'),
            subtitle: Text('Access tokens belong in secure storage.'),
          ),
        ),
      ],
    );
  }
}
