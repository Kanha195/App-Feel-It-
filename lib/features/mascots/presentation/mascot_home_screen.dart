import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/weather_service.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../weather/models/weather_state.dart';
import '../models/mascot.dart';

final weatherProvider = FutureProvider<WeatherState>(
  (ref) => WeatherService().fetch(),
);

class MascotHomeScreen extends ConsumerWidget {
  const MascotHomeScreen({super.key});

  Mascot _mascotFor(WeatherState weather, MascotType type) {
    if (weather.needsSnowGear) {
      return Mascot(type: type, mood: MascotMood.cold, outfitId: 'winter_snow');
    }
    if (weather.needsRainGear) {
      return Mascot(type: type, mood: MascotMood.rainy, outfitId: 'raincoat');
    }
    if (weather.needsWarmClothes) {
      return Mascot(type: type, mood: MascotMood.cold, outfitId: 'warm_jacket');
    }
    return Mascot(type: type);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);

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
        weatherError: true,
      ),
      data: (value) => _content(context, value),
    );
  }

  Widget _content(
    BuildContext context,
    WeatherState weather, {
    bool weatherError = false,
  }) {
    final dowie = _mascotFor(weather, MascotType.dowie);
    final snowie = _mascotFor(weather, MascotType.snowie);

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
                    _MascotCard(mascot: dowie, asset: 'assets/images/dowie.png'),
                    _MascotCard(mascot: snowie, asset: 'assets/images/snowie.png'),
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
            ),
            _ActionCard(
              icon: Icons.checkroom,
              title: 'Wardrobe',
              subtitle: 'Dress your mascots',
            ),
            _ActionCard(
              icon: Icons.route,
              title: 'Tours',
              subtitle: 'Find your next pass',
            ),
            _ActionCard(
              icon: Icons.local_cafe,
              title: 'Rewards',
              subtitle: 'Unlock teahouses',
            ),
          ],
        ),
        const SizedBox(height: 16),
        NeonButton(
          label: 'OPEN LIVE RADAR',
          icon: Icons.radar,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _MascotCard extends StatelessWidget {
  const _MascotCard({required this.mascot, required this.asset});

  final Mascot mascot;
  final String asset;

  @override
  Widget build(BuildContext context) {
    final outfit = switch (mascot.outfitId) {
      'raincoat' => 'Raincoat activated',
      'winter_snow' => 'Winter gear activated',
      'warm_jacket' => 'Warm jacket activated',
      _ => 'Default outfit',
    };

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              asset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.pets,
                size: 90,
                color: Color(0xFF00F5D4),
              ),
            ),
          ),
          Text(mascot.name, style: const TextStyle(fontWeight: FontWeight.w900)),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF00F5D4), size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
