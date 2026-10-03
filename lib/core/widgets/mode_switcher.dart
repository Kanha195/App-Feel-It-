import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/app_state.dart';

class ModeSwitcher extends ConsumerWidget {
  const ModeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);

    return SegmentedButton<AppMode>(
      segments: const [
        ButtonSegment(
          value: AppMode.traveler,
          icon: Icon(Icons.explore),
          label: Text('Traveler'),
        ),
        ButtonSegment(
          value: AppMode.captain,
          icon: Icon(Icons.radar),
          label: Text('Captain'),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (values) {
        ref.read(appModeProvider.notifier).setMode(values.first);
      },
    );
  }
}
