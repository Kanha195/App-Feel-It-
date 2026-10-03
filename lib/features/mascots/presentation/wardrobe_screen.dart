import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/glass_card.dart';
import '../../../shared/providers/app_state.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  static const outfits = <String, String>{
    'trail': 'Trail layers',
    'summit': 'Summit shell',
    'raincoat': 'Monsoon coat',
    'winter_snow': 'Snow suit',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipped = ref.watch(mascotOutfitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dowie & Snowie wardrobe')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Choose a look for the next ride.'),
          const SizedBox(height: 16),
          for (final mascot in ['dowie', 'snowie'])
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mascot == 'dowie' ? 'Dowie' : 'Snowie',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: outfits.entries.map((entry) {
                        final selected = equipped[mascot] == entry.key;
                        return ChoiceChip(
                          label: Text(entry.value),
                          selected: selected,
                          onSelected: (_) => ref
                              .read(mascotOutfitsProvider.notifier)
                              .equip(mascot, entry.key),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          const GlassCard(
            child: ListTile(
              leading: Icon(Icons.lock_outline, color: Color(0xFFFFB703)),
              title: Text('More gear on the trail'),
              subtitle: Text('Checkpoint and tour rewards will appear here.'),
            ),
          ),
        ],
      ),
    );
  }
}
