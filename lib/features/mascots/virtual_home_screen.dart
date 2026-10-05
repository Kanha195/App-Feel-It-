import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../weather/models/weather_state.dart';
import 'providers/virtual_home_providers.dart';

class VirtualHomeScreen extends ConsumerStatefulWidget {
  const VirtualHomeScreen({super.key});

  @override
  ConsumerState<VirtualHomeScreen> createState() => _VirtualHomeScreenState();
}

class _VirtualHomeScreenState extends ConsumerState<VirtualHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..repeat();

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherSnapshot = ref.watch(virtualHomeWeatherProvider);
    final snapshot = weatherSnapshot.valueOrNull;
    final weather = snapshot?.weather;
    final careStats = ref.watch(mascotCareProvider);
    final dowie = careStats['dowie'] ?? const MascotCareStats();
    final snowie = careStats['snowie'] ?? const MascotCareStats();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DOWIE & SNOWIE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.neonTeal,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Their little world',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Refresh weather',
              onPressed: () => ref.invalidate(virtualHomeWeatherProvider),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _WeatherCard(
          snapshot: snapshot,
          isLoading: weatherSnapshot.isLoading,
          useCurrentLocation: ref.watch(virtualHomeUseCurrentLocationProvider),
          onLocationChanged: (enabled) => ref
              .read(virtualHomeUseCurrentLocationProvider.notifier)
              .useCurrentLocation(enabled),
        ),
        const SizedBox(height: 14),
        _GlassPanel(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
                child: Row(
                  children: [
                    const Icon(Icons.home_work_rounded,
                        color: AppColors.sunsetGold, size: 19),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'THE LITTLE HIMALAYAN HOME',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    Text(
                      'TAP TO EXPLORE',
                      style: TextStyle(
                        color: AppColors.neonTeal.withValues(alpha: .75),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth,
                      constraints.maxWidth * 0.70);
                  return SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (details) => _onHomeTap(
                            details.localPosition,
                            size,
                            weather,
                          ),
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, _) => CustomPaint(
                              painter: _IsometricHomePainter(
                                phase: _animation.value,
                                weather: weather,
                              ),
                            ),
                          ),
                        ),
                        _MascotMarker(
                          name: 'Dowie',
                          emoji: '🐶',
                          left: size.width * .17,
                          top: size.height * .40,
                          onTap: () => _showCareSheet('dowie', weather),
                        ),
                        _MascotMarker(
                          name: 'Snowie',
                          emoji: '🐱',
                          left: size.width * .61,
                          top: size.height * .20,
                          onTap: () => _showCareSheet('snowie', weather),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 6),
                child: Text(
                  'A living little home that changes with the weather.',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _CareSummaryCard(
                name: 'Dowie',
                emoji: '🐶',
                stats: dowie,
                onTap: () => _showCareSheet('dowie', weather),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CareSummaryCard(
                name: 'Snowie',
                emoji: '🐱',
                stats: snowie,
                onTap: () => _showCareSheet('snowie', weather),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onHomeTap(
    Offset position,
    Size size,
    WeatherState? weather,
  ) {
    final point = Offset(
      position.dx / size.width * 1000,
      position.dy / size.height * 700,
    );
    if (_containsPoint(point, const [
      Offset(60, 330),
      Offset(260, 210),
      Offset(500, 345),
      Offset(275, 485),
    ])) {
      _showRoomSheet('Garden & pond', 'dowie', weather);
    } else if (_containsPoint(point, const [
      Offset(260, 210),
      Offset(500, 68),
      Offset(745, 208),
      Offset(500, 345),
    ])) {
      _showRoomSheet('Cozy bedroom', 'snowie', weather);
    } else if (_containsPoint(point, const [
      Offset(500, 345),
      Offset(745, 208),
      Offset(950, 330),
      Offset(715, 485),
    ])) {
      _showRoomSheet('Kitchen & dining', 'dowie', weather);
    } else if (_containsPoint(point, const [
      Offset(275, 485),
      Offset(500, 345),
      Offset(715, 485),
      Offset(500, 630),
    ])) {
      _showRoomSheet('Washroom', 'snowie', weather);
    } else {
      _showRoomSheet('Little home', 'dowie', weather);
    }
  }

  bool _containsPoint(Offset point, List<Offset> polygon) {
    var inside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final current = polygon[i];
      final previous = polygon[j];
      final crosses = (current.dy > point.dy) != (previous.dy > point.dy);
      if (crosses &&
          point.dx <
              (previous.dx - current.dx) *
                      (point.dy - current.dy) /
                      (previous.dy - current.dy) +
                  current.dx) {
        inside = !inside;
      }
    }
    return inside;
  }

  void _showCareSheet(String mascot, WeatherState? weather) {
    final name = mascot == 'dowie' ? 'Dowie' : 'Snowie';
    _showInteractionSheet(
      title: 'Visit $name',
      subtitle: _mascotStatus(name, weather),
      mascot: mascot,
      room: false,
    );
  }

  void _showRoomSheet(
    String room,
    String mascot,
    WeatherState? weather,
  ) {
    final name = mascot == 'dowie' ? 'Dowie' : 'Snowie';
    final (description, actionLabel, icon) = switch (room) {
      'Garden & pond' => (
          'The pond is rippling and the garden is ready for a little play.',
          'PLAY TOGETHER',
          Icons.sports_basketball_rounded,
        ),
      'Kitchen & dining' => (
          '$name is waiting for a tasty snack at the dining table.',
          'SERVE A SNACK',
          Icons.restaurant_rounded,
        ),
      'Cozy bedroom' => (
          'The bedside lamp is warm and the pillows are extra fluffy.',
          'SETTLE DOWN',
          Icons.bedtime_rounded,
        ),
      'Washroom' => (
          'Fresh towels and a gentle grooming session are ready.',
          'GROOM',
          Icons.spa_rounded,
        ),
      _ => (
          _mascotStatus(name, weather),
          'CHECK ON $name',
          Icons.favorite_rounded,
        ),
    };
    _showInteractionSheet(
      title: room,
      subtitle: description,
      mascot: mascot,
      room: true,
      actionLabel: actionLabel,
      actionIcon: icon,
    );
  }

  String _mascotStatus(String name, WeatherState? weather) {
    if (weather?.needsRainGear ?? false) {
      return '$name is listening to the rain from the cozy, dry home.';
    }
    if (weather?.needsWarmClothes ?? false) {
      return '$name is staying warm while the mountain air is chilly.';
    }
    if (weather?.condition == WeatherCondition.clear) {
      return '$name is enjoying the sunshine across the little home.';
    }
    return '$name is happy at home. Choose an activity to brighten their day.';
  }

  void _showInteractionSheet({
    required String title,
    required String subtitle,
    required String mascot,
    required bool room,
    String? actionLabel,
    IconData? actionIcon,
  }) {
    final stats = ref.read(mascotCareProvider)[mascot] ??
        const MascotCareStats();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final controller = ref.read(mascotCareProvider.notifier);
        final quickAction = room ? _roomAction(title) : null;

        return _GlassPanel(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.neonTeal.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      actionIcon ?? Icons.pets_rounded,
                      color: AppColors.neonTeal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w900)),
                        Text(subtitle,
                            style: const TextStyle(
                                color: AppColors.muted, height: 1.35)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _CareMeters(stats: stats),
              const SizedBox(height: 18),
              if (quickAction != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      quickAction(controller, mascot);
                      Navigator.of(sheetContext).pop();
                    },
                    icon: Icon(actionIcon ?? Icons.favorite_rounded),
                    label: Text(actionLabel ?? 'CARE FOR MASCOT'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.neonTeal,
                      foregroundColor: AppColors.midnight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _CareAction(
                      label: 'Feed',
                      icon: Icons.restaurant_rounded,
                      onTap: () => _performCare(
                          sheetContext, controller.feed, mascot),
                    ),
                    _CareAction(
                      label: 'Rest',
                      icon: Icons.bedtime_rounded,
                      onTap: () =>
                          _performCare(sheetContext, controller.rest, mascot),
                    ),
                    _CareAction(
                      label: 'Groom',
                      icon: Icons.spa_rounded,
                      onTap: () =>
                          _performCare(sheetContext, controller.groom, mascot),
                    ),
                    _CareAction(
                      label: 'Play',
                      icon: Icons.sports_basketball_rounded,
                      onTap: () =>
                          _performCare(sheetContext, controller.play, mascot),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  void Function(MascotCareController, String)? _roomAction(String room) {
    return switch (room) {
      'Garden & pond' => (controller, mascot) => controller.play(mascot),
      'Kitchen & dining' => (controller, mascot) => controller.feed(mascot),
      'Cozy bedroom' => (controller, mascot) => controller.rest(mascot),
      'Washroom' => (controller, mascot) => controller.groom(mascot),
      _ => null,
    };
  }

  void _performCare(
    BuildContext sheetContext,
    void Function(String) action,
    String mascot,
  ) {
    action(mascot);
    Navigator.of(sheetContext).pop();
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({
    required this.snapshot,
    required this.isLoading,
    required this.useCurrentLocation,
    required this.onLocationChanged,
  });

  final VirtualHomeWeatherSnapshot? snapshot;
  final bool isLoading;
  final bool useCurrentLocation;
  final ValueChanged<bool> onLocationChanged;

  @override
  Widget build(BuildContext context) {
    final weather = snapshot?.weather;
    final icon = weather == null
        ? Icons.cloud_off_rounded
        : weather.needsRainGear
            ? Icons.umbrella_rounded
            : weather.needsSnowGear || weather.needsWarmClothes
                ? Icons.ac_unit_rounded
                : weather.condition == WeatherCondition.clear
                    ? Icons.wb_sunny_rounded
                    : Icons.cloud_rounded;

    return _GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.sunsetGold.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.sunsetGold, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather == null
                          ? 'Live weather'
                          : '${weather.temperature.toStringAsFixed(0)}° · ${weather.label}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      snapshot?.location ?? 'Connecting to Open-Meteo…',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading && snapshot == null)
                const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.neonTeal,
                  ),
                )
              else
                Icon(Icons.circle,
                    size: 9,
                    color: weather == null
                        ? AppColors.sunsetGold
                        : AppColors.neonTeal),
            ],
          ),
          if (snapshot?.message != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                snapshot!.message!,
                style: const TextStyle(
                  color: AppColors.sunsetGold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
          const SizedBox(height: 7),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Open-Meteo · updates every 5 minutes',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ),
              Text(
                'USE GPS',
                style: TextStyle(
                  color: useCurrentLocation
                      ? AppColors.neonTeal
                      : AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(width: 5),
              SizedBox(
                height: 28,
                child: Switch.adaptive(
                  value: useCurrentLocation,
                  activeColor: AppColors.neonTeal,
                  onChanged: onLocationChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CareSummaryCard extends StatelessWidget {
  const _CareSummaryCard({
    required this.name,
    required this.emoji,
    required this.stats,
    required this.onTap,
  });

  final String name;
  final String emoji;
  final MascotCareStats stats;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: _GlassPanel(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 14)),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.muted, size: 18),
                ],
              ),
              const SizedBox(height: 10),
              _CompactMeter(label: 'Full', value: stats.fullness),
              const SizedBox(height: 5),
              _CompactMeter(label: 'Energy', value: stats.energy),
            ],
          ),
        ),
      );
}

class _CareMeters extends StatelessWidget {
  const _CareMeters({required this.stats});

  final MascotCareStats stats;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _CareMeter(label: 'Fullness', value: stats.fullness),
          _CareMeter(label: 'Energy', value: stats.energy),
          _CareMeter(label: 'Freshness', value: stats.cleanliness),
          _CareMeter(label: 'Joy', value: stats.joy),
        ],
      );
}

class _CareMeter extends StatelessWidget {
  const _CareMeter({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(label,
                  style:
                      const TextStyle(color: AppColors.muted, fontSize: 12)),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: value / 100,
                  minHeight: 7,
                  backgroundColor: AppColors.line.withValues(alpha: .45),
                  color: value < 30 ? AppColors.sunsetGold : AppColors.neonTeal,
                ),
              ),
            ),
            SizedBox(
              width: 38,
              child: Text(
                '$value%',
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 11, color: AppColors.white),
              ),
            ),
          ],
        ),
      );
}

class _CompactMeter extends StatelessWidget {
  const _CompactMeter({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(label,
                style: const TextStyle(color: AppColors.muted, fontSize: 9)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 5,
                backgroundColor: AppColors.line.withValues(alpha: .45),
                color: AppColors.neonTeal,
              ),
            ),
          ),
        ],
      );
}

class _CareAction extends StatelessWidget {
  const _CareAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
        avatar: Icon(icon, color: AppColors.neonTeal, size: 17),
        label: Text(label),
        onPressed: onTap,
        backgroundColor: AppColors.midnightSurface,
        side: BorderSide(color: AppColors.neonTeal.withValues(alpha: .2)),
        labelStyle: const TextStyle(color: AppColors.white),
      );
}

class _MascotMarker extends StatelessWidget {
  const _MascotMarker({
    required this.name,
    required this.emoji,
    required this.left,
    required this.top,
    required this.onTap,
  });

  final String name;
  final String emoji;
  final double left;
  final double top;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Positioned(
        left: left,
        top: top,
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 37,
                height: 37,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.midnightSurface.withValues(alpha: .93),
                  border: Border.all(
                      color: AppColors.neonTeal.withValues(alpha: .8)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonTeal.withValues(alpha: .25),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: AppColors.midnight, blurRadius: 5)],
                ),
              ),
            ],
          ),
        ),
      );
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0xD9111827),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.neonTeal.withValues(alpha: .16)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1800F5D4),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: child,
      );
}

class _IsometricHomePainter extends CustomPainter {
  const _IsometricHomePainter({required this.phase, required this.weather});

  final double phase;
  final WeatherState? weather;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 1000, size.height / 700);

    final isRainy = weather?.needsRainGear ?? false;
    final isCold = weather?.needsWarmClothes ?? false;
    final sky = isRainy
        ? const Color(0xFF18283A)
        : isCold
            ? const Color(0xFF202C45)
            : const Color(0xFF152A36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 1000, 700),
        const Radius.circular(24),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [sky, const Color(0xFF101923)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(const Rect.fromLTWH(0, 0, 1000, 700)),
    );

    if (!isRainy && weather?.condition == WeatherCondition.clear) {
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.sunsetGold.withValues(alpha: .18),
            AppColors.sunsetGold.withValues(alpha: 0),
          ],
        ).createShader(const Rect.fromCircle(
          center: Offset(810, 100),
          radius: 210,
        ));
      canvas.drawCircle(const Offset(810, 100), 210, glow);
    }

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: .34)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    _polygon(canvas, const [
      Offset(76, 354),
      Offset(497, 92),
      Offset(927, 340),
      Offset(508, 633),
    ], shadow);

    _polygon(
      canvas,
      const [
        Offset(60, 330),
        Offset(500, 68),
        Offset(950, 330),
        Offset(500, 630),
      ],
      Paint()..color = const Color(0xFF344B48),
      stroke: Paint()
        ..color = AppColors.neonTeal.withValues(alpha: .55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    _polygon(canvas, const [
      Offset(60, 330),
      Offset(260, 210),
      Offset(500, 345),
      Offset(275, 485),
    ], Paint()..color = const Color(0xFF315A42));
    _polygon(canvas, const [
      Offset(260, 210),
      Offset(500, 68),
      Offset(745, 208),
      Offset(500, 345),
    ], Paint()..color = const Color(0xFF53483F));
    _polygon(canvas, const [
      Offset(500, 345),
      Offset(745, 208),
      Offset(950, 330),
      Offset(715, 485),
    ], Paint()..color = const Color(0xFF4A5148));
    _polygon(canvas, const [
      Offset(275, 485),
      Offset(500, 345),
      Offset(715, 485),
      Offset(500, 630),
    ], Paint()..color = const Color(0xFF42514D));

    final seams = Paint()
      ..color = const Color(0x557F9C8F)
      ..strokeWidth = 2;
    _line(canvas, const Offset(260, 210), const Offset(275, 485), seams);
    _line(canvas, const Offset(745, 208), const Offset(715, 485), seams);
    _line(canvas, const Offset(500, 345), const Offset(500, 630), seams);
    _line(canvas, const Offset(260, 210), const Offset(745, 208), seams);
    _line(canvas, const Offset(275, 485), const Offset(715, 485), seams);

    _drawGarden(canvas, phase);
    _drawBedroom(canvas, phase, isRainy);
    _drawKitchen(canvas, phase);
    _drawWashroom(canvas);
    _drawRoomLabel(canvas, 'GARDEN & POND', const Offset(126, 366));
    _drawRoomLabel(canvas, 'COZY BEDROOM', const Offset(361, 145));
    _drawRoomLabel(canvas, 'KITCHEN & DINING', const Offset(682, 312));
    _drawRoomLabel(canvas, 'WASHROOM', const Offset(439, 542));

    if (isRainy) {
      final rainPaint = Paint()
        ..color = const Color(0x7786D9FF)
        ..strokeWidth = 2;
      for (var i = 0; i < 30; i++) {
        final x = (i * 137 + phase * 520) % 1000;
        final y = (i * 73 + phase * 740) % 700;
        canvas.drawLine(Offset(x, y), Offset(x - 7, y + 16), rainPaint);
      }
    }

    canvas.restore();
  }

  void _drawGarden(Canvas canvas, double phase) {
    final grass = Paint()..color = const Color(0xFF77A75F);
    for (final point in const [
      Offset(127, 291),
      Offset(208, 253),
      Offset(119, 403),
      Offset(330, 412),
      Offset(366, 338),
    ]) {
      canvas.drawCircle(point, 11, grass);
      canvas.drawCircle(
        point.translate(2, -3),
        5,
        Paint()..color = const Color(0xFFA7CB75),
      );
    }
    final pond = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF137F91), Color(0xFF184B69)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(142, 347, 190, 98));
    _oval(canvas, const Rect.fromLTWH(142, 347, 190, 98), pond);
    _oval(
      canvas,
      const Rect.fromLTWH(142, 347, 190, 98),
      Paint()
        ..color = AppColors.neonTeal.withValues(alpha: .65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    for (var i = 0; i < 3; i++) {
      final ripplePhase = (phase + i / 3) % 1;
      final width = 24 + ripplePhase * 68;
      final opacity = (1 - ripplePhase) * .58;
      _oval(
        canvas,
        Rect.fromCenter(
          center: Offset(236, 393),
          width: width,
          height: width * .38,
        ),
        Paint()
          ..color = AppColors.neonTeal.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    _drawFlower(canvas, const Offset(111, 343), const Color(0xFFFFD166));
    _drawFlower(canvas, const Offset(349, 396), const Color(0xFFFF8FB1));
    _drawFlower(canvas, const Offset(362, 300), const Color(0xFFFFD166));
    _polygon(canvas, const [
      Offset(157, 306),
      Offset(192, 284),
      Offset(222, 301),
      Offset(187, 324),
    ], Paint()..color = const Color(0xFF886C4D));
  }

  void _drawBedroom(Canvas canvas, double phase, bool rainy) {
    final lampGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.sunsetGold.withValues(alpha: rainy ? .32 : .20),
          AppColors.sunsetGold.withValues(alpha: 0),
        ],
      ).createShader(const Rect.fromCircle(
        center: Offset(635, 181),
        radius: 115,
      ));
    canvas.drawCircle(const Offset(635, 181), 115, lampGlow);

    _polygon(canvas, const [
      Offset(329, 232),
      Offset(417, 179),
      Offset(569, 267),
      Offset(480, 324),
    ], Paint()..color = const Color(0xFF7C5366));
    _polygon(canvas, const [
      Offset(329, 232),
      Offset(480, 324),
      Offset(480, 347),
      Offset(329, 255),
    ], Paint()..color = const Color(0xFF573C51));
    _polygon(canvas, const [
      Offset(417, 179),
      Offset(569, 267),
      Offset(569, 290),
      Offset(480, 347),
      Offset(480, 324),
    ], Paint()..color = const Color(0xFF644354));
    _polygon(canvas, const [
      Offset(351, 228),
      Offset(418, 187),
      Offset(468, 216),
      Offset(401, 258),
    ], Paint()..color = const Color(0xFFE8DCCB));
    _polygon(canvas, const [
      Offset(418, 187),
      Offset(477, 221),
      Offset(468, 245),
      Offset(401, 258),
    ], Paint()..color = const Color(0xFFB8CFD0));

    canvas.drawCircle(
      const Offset(635, 190),
      18 + math.sin(phase * math.pi * 2).abs() * 2,
      Paint()..color = AppColors.sunsetGold,
    );
    _polygon(canvas, const [
      Offset(620, 209),
      Offset(650, 209),
      Offset(661, 236),
      Offset(610, 236),
    ], Paint()..color = const Color(0xFFFFD77B));
    _line(
      canvas,
      const Offset(610, 236),
      const Offset(661, 236),
      Paint()
        ..color = AppColors.sunsetGold
        ..strokeWidth = 4,
    );
    _polygon(canvas, const [
      Offset(297, 279),
      Offset(318, 266),
      Offset(338, 278),
      Offset(317, 291),
    ], Paint()..color = const Color(0xFF5A916F));
  }

  void _drawKitchen(Canvas canvas, double phase) {
    _polygon(canvas, const [
      Offset(594, 271),
      Offset(724, 197),
      Offset(851, 271),
      Offset(721, 350),
    ], Paint()..color = const Color(0xFF986B50));
    _polygon(canvas, const [
      Offset(594, 271),
      Offset(721, 350),
      Offset(721, 372),
      Offset(594, 293),
    ], Paint()..color = const Color(0xFF65483C));
    _polygon(canvas, const [
      Offset(721, 350),
      Offset(851, 271),
      Offset(851, 293),
      Offset(721, 372),
    ], Paint()..color = const Color(0xFF74513F));
    _polygon(canvas, const [
      Offset(632, 259),
      Offset(723, 206),
      Offset(815, 260),
      Offset(722, 315),
    ], Paint()..color = const Color(0xFFFFDDA5));
    _oval(
      canvas,
      Rect.fromCenter(
        center: Offset(719, 263),
        width: 95,
        height: 42,
      ),
      Paint()
        ..color = AppColors.neonTeal.withValues(
          alpha: .09 + .07 * math.sin(phase * math.pi * 2).abs(),
        ),
    );
    _polygon(canvas, const [
      Offset(770, 345),
      Offset(836, 305),
      Offset(865, 322),
      Offset(799, 363),
    ], Paint()..color = const Color(0xFFD3A76A));
    _line(
      canvas,
      const Offset(781, 358),
      const Offset(789, 393),
      Paint()
        ..color = const Color(0xFF77573F)
        ..strokeWidth = 5,
    );
    _line(
      canvas,
      const Offset(845, 326),
      const Offset(850, 361),
      Paint()
        ..color = const Color(0xFF77573F)
        ..strokeWidth = 5,
    );
    _oval(
      canvas,
      const Rect.fromLTWH(625, 216, 36, 15),
      Paint()..color = AppColors.sunsetGold,
    );
  }

  void _drawWashroom(Canvas canvas) {
    _polygon(canvas, const [
      Offset(330, 481),
      Offset(418, 426),
      Offset(511, 480),
      Offset(421, 535),
    ], Paint()..color = const Color(0xFF7898A0));
    _polygon(canvas, const [
      Offset(348, 476),
      Offset(419, 434),
      Offset(486, 474),
      Offset(418, 516),
    ], Paint()..color = const Color(0xFFA9D4D7));
    _oval(
      canvas,
      const Rect.fromLTWH(387, 461, 66, 35),
      Paint()..color = const Color(0xFF548E9A),
    );
    _oval(
      canvas,
      const Rect.fromLTWH(403, 467, 33, 16),
      Paint()..color = const Color(0xFFBDE9E7),
    );
    _polygon(canvas, const [
      Offset(555, 438),
      Offset(590, 418),
      Offset(627, 439),
      Offset(591, 461),
    ], Paint()..color = const Color(0xFFE7E0D2));
    _oval(
      canvas,
      const Rect.fromLTWH(566, 433, 47, 22),
      Paint()..color = const Color(0xFF70B9BD),
    );
    canvas.drawCircle(
      const Offset(515, 426),
      15,
      Paint()..color = const Color(0xFF79A875),
    );
  }

  void _drawRoomLabel(Canvas canvas, String text, Offset center) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = Rect.fromCenter(
      center: center,
      width: painter.width + 22,
      height: painter.height + 14,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()..color = const Color(0xD90B0F19),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()
        ..color = AppColors.neonTeal.withValues(alpha: .35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  void _drawFlower(Canvas canvas, Offset center, Color color) {
    final paint = Paint()..color = color;
    for (var i = 0; i < 5; i++) {
      final angle = i * math.pi * 2 / 5;
      canvas.drawCircle(
        center + Offset(math.cos(angle) * 6, math.sin(angle) * 6),
        4,
        paint,
      );
    }
    canvas.drawCircle(center, 3, Paint()..color = AppColors.sunsetGold);
  }

  void _polygon(
    Canvas canvas,
    List<Offset> points,
    Paint paint, {
    Paint? stroke,
  }) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
    if (stroke != null) canvas.drawPath(path, stroke);
  }

  void _line(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);
  }

  void _oval(Canvas canvas, Rect rect, Paint paint) {
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _IsometricHomePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.weather != weather;
}
