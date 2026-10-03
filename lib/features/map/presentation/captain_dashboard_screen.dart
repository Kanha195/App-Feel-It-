import 'package:flutter/material.dart';

import '../../../core/widgets/glass_card.dart';
import 'live_radar_screen.dart';

class CaptainDashboardScreen extends StatefulWidget {
  const CaptainDashboardScreen({super.key});

  @override
  State<CaptainDashboardScreen> createState() => _CaptainDashboardScreenState();
}

class _CaptainDashboardScreenState extends State<CaptainDashboardScreen> {
  bool _routeBriefed = false;
  bool _regroupRequested = false;
  bool _sweepRole = false;

  void _openRadar() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LiveRadarScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Captain console',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        const Text('Guide controls for today’s Himalayan convoy.'),
        const SizedBox(height: 18),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.radar, color: colors.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Convoy telemetry',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const Text('GPS idle'),
                ],
              ),
              const SizedBox(height: 12),
              const Text('No live rider locations until tracking is started.'),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _openRadar,
                icon: const Icon(Icons.my_location),
                label: const Text('Open live radar'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _routeBriefed,
                onChanged: (value) => setState(() => _routeBriefed = value),
                title: const Text('Route briefing complete'),
                secondary: const Icon(Icons.route),
              ),
              const Divider(height: 1),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _sweepRole,
                onChanged: (value) => setState(() => _sweepRole = value),
                title: const Text('Sweep rider role'),
                secondary: const Icon(Icons.groups_outlined),
              ),
              const Divider(height: 1),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _regroupRequested,
                onChanged: (value) => setState(() => _regroupRequested = value),
                title: const Text('Regroup riders'),
                secondary: const Icon(Icons.flag_outlined),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
