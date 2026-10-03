import 'package:flutter/material.dart';

import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/neon_button.dart';

class ToursScreen extends StatelessWidget {
  const ToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tours = [
      ('Kathmandu → Pokhara', '2 days • Himalayan foothills'),
      ('Pokhara → Mustang', '5 days • High altitude'),
      ('Langtang Loop', '4 days • Mountain roads'),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Tour catalogue', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 14),
        ...tours.map(
          (tour) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.$1,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(tour.$2),
                  const SizedBox(height: 14),
                  NeonButton(
                    label: 'BOOK VIA WHATSAPP',
                    icon: Icons.chat,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
