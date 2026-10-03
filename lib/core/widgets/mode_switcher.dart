import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/app_state.dart';

class ModeSwitcher extends ConsumerWidget {
  const ModeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);
    final compact = MediaQuery.sizeOf(context).width < 560;

    return SegmentedButton<AppMode>(
      showSelectedIcon: false,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
      ),
      segments: [
        ButtonSegment(
          value: AppMode.traveler,
          icon: const Icon(Icons.explore),
          label: Text(compact ? 'Ride' : 'Traveler'),
          tooltip: 'Traveler Mode',
        ),
        ButtonSegment(
          value: AppMode.captain,
          icon: const Icon(Icons.radar),
          label: Text(compact ? 'Guide' : 'Captain'),
          tooltip: 'Captain Mode',
        ),
      ],
      selected: {mode},
      onSelectionChanged: (values) {
        ref.read(appModeProvider.notifier).setMode(values.first);
      },
    );
  }
}
