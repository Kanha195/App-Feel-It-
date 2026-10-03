import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_state.dart';
import '../../../core/services/weather_service.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../garage/presentation/garage_screen.dart';
import '../../map/presentation/live_radar_screen.dart';
import '../../mechanic/presentation/mechanic_scanner_screen.dart';
import '../../tours/presentation/tours_screen.dart';
import '../../weather/models/weather_state.dart';
import '../models/mascot.dart';
import 'wardrobe_screen.dart';

final weatherProvider = StreamProvider<WeatherState>((ref) async* {
  final service = WeatherService();
  while (true) {
    try {
      yield await service.fetch();
    } catch (_) {
      yield const WeatherState(
        temperature: 0,
        windSpeed: 0,
        weatherCode: -1,
        condition: WeatherCondition.unknown,
      );
    }
    await Future<void>.delayed(const Duration(minutes: 5));
  }
});

class MascotHomeScreen extends ConsumerWidget {
  const MascotHomeScreen({super.key});

  Mascot _mascotFor(
      WeatherState weather, MascotType type, String selectedOutfit) {
    if (weather.needsSnowGear) {
      return Mascot(type: type, mood: MascotMood.cold, outfitId: 'winter_snow');
    }
    if (weather.needsRainGear) {
      return Mascot(type: type, mood: MascotMood.rainy, outfitId: 'raincoat');
    }
    if (weather.needsWarmClothes) {
      return Mascot(type: type, mood: MascotMood.cold, outfitId: 'warm_jacket');
    }
    return Mascot(type: type, outfitId: selectedOutfit);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);
    final outfits = ref.watch(mascotOutfitsProvider);

    return weather.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _content(
        context,
        const WeatherState(
          temperature: 0,
          windSpeed: 0,
          weatherCode: -1,
          condition: WeatherCondition.unknown,
        ),
        outfits: outfits,
        weatherError: true,
      ),
      data: (value) => _content(context, value, outfits: outfits),
    );
  }

  Widget _content(
    BuildContext context,
    WeatherState weather, {
    required Map<String, String> outfits,
    bool weatherError = false,
  }) {
    final dowie =
        _mascotFor(weather, MascotType.dowie, outfits['dowie'] ?? 'trail');
    final snowie =
        _mascotFor(weather, MascotType.snowie, outfits['snowie'] ?? 'summit');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR HIMALAYAN STAGE',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF00F5D4),
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to ride?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 230,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MascotCard(
                        mascot: dowie, asset: 'assets/images/dowie.png'),
                    _MascotCard(
                        mascot: snowie, asset: 'assets/images/snowie.png'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Row(
            children: [
              const Icon(Icons.cloud, color: Color(0xFFFFB703), size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weatherError ? 'Weather offline' : 'Kathmandu weather',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      weatherError
                          ? 'Showing safe default mascot state'
                          : '${weather.temperature.toStringAsFixed(0)}°C • ${weather.label} • ${weather.windSpeed.toStringAsFixed(0)} km/h',
                    ),
                  ],
                ),
              ),
              Icon(
                weather.needsRainGear
                    ? Icons.umbrella
                    : weather.needsWarmClothes
                        ? Icons.ac_unit
                        : Icons.wb_sunny,
                color: const Color(0xFF00F5D4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _ActionCard(
              icon: Icons.two_wheeler,
              title: 'Garage',
              subtitle: 'Your machines',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const GarageScreen()),
              ),
            ),
            _ActionCard(
              icon: Icons.checkroom,
              title: 'Wardrobe',
              subtitle: 'Dress your mascots',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const WardrobeScreen()),
              ),
            ),
            _ActionCard(
              icon: Icons.route,
              title: 'Tours',
              subtitle: 'Find your next pass',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ToursScreen()),
              ),
            ),
            _ActionCard(
              icon: Icons.local_cafe,
              title: 'Rewards',
              subtitle: 'Unlock teahouses',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => const LiveRadarScreen()),
              ),
            ),
            _ActionCard(
              icon: Icons.build,
              title: 'Mechanic',
              subtitle: 'Scan your bike',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MechanicScannerScreen(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        NeonButton(
          label: 'OPEN LIVE RADAR',
          icon: Icons.radar,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const LiveRadarScreen()),
          ),
        ),
      ],
    );
  }
}

class _MascotCard extends StatefulWidget {
  const _MascotCard({required this.mascot, required this.asset});

  final Mascot mascot;
  final String asset;

  @override
  State<_MascotCard> createState() => _MascotCardState();
}

class _MascotCardState extends State<_MascotCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outfit = switch (widget.mascot.outfitId) {
      'raincoat' => 'Raincoat activated',
      'winter_snow' => 'Winter gear activated',
      'warm_jacket' => 'Warm jacket activated',
      'summit' => 'Summit shell',
      'trail' => 'Trail layers',
      _ => 'Default outfit',
    };

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _float,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, math.sin(_float.value * math.pi) * -7),
                child: child,
              ),
              child: Image.asset(
                widget.asset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 128,
                  height: 128,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFF294451), Color(0xFF111827)],
                    ),
                    boxShadow: [
                      BoxShadow(color: Color(0x4400F5D4), blurRadius: 24),
                    ],
                  ),
                  child: const Text('🦌', style: TextStyle(fontSize: 72)),
                ),
              ),
            ),
          ),
          Text(widget.mascot.name,
              style: const TextStyle(fontWeight: FontWeight.w900)),
          Text(outfit, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        borderRadius: 12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF00F5D4), size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
