import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/glass_card.dart';
import '../models/checkpoint.dart';
import '../services/checkpoint_validator.dart';
import '../services/checkpoint_reward_service.dart';
import '../services/gps_tracker.dart';

class LiveRadarScreen extends StatefulWidget {
  const LiveRadarScreen({super.key});

  @override
  State<LiveRadarScreen> createState() => _LiveRadarScreenState();
}

class _LiveRadarScreenState extends State<LiveRadarScreen> {
  final MapController mapController = MapController();
  final GpsTracker tracker = GpsTracker();
  final LocationService locationService = LocationService();
  final CheckpointRewardService rewardService = CheckpointRewardService();

  Position? position;
  String status = 'GPS waiting';
  CheckpointValidation? lastCheckpoint;
  bool tracking = false;
  final Set<String> gpsReached = {};
  final Set<String> verifiedRewards = {};
  final Set<String> pendingVerification = {};
  final Set<String> attemptedVerification = {};

  final checkpoints = const [
    Checkpoint(
      id: 'thamel-teahouse',
      name: 'Thamel Momo Stop',
      latitude: 27.7153,
      longitude: 85.3123,
      unlockRadiusMeters: 80,
      rewardId: 'momo-01',
    ),
    Checkpoint(
      id: 'boudha-tea',
      name: 'Boudha Tea Stop',
      latitude: 27.7215,
      longitude: 85.3620,
      unlockRadiusMeters: 80,
      rewardId: 'tea-01',
    ),
  ];

  Future<void> toggleTracking() async {
    if (tracking) {
      await tracker.stop();
      setState(() {
        tracking = false;
        status = 'GPS paused';
      });
      return;
    }

    final allowed = await locationService.ensurePermission();
    if (!allowed) {
      setState(() => status = 'Location permission/service unavailable');
      return;
    }

    tracker.start(
      checkpoints: checkpoints,
      onPosition: (value) {
        if (!mounted) return;
        setState(() {
          position = value;
          status = 'Live GPS • ±${value.accuracy.toStringAsFixed(0)}m';
        });
        mapController.move(
          LatLng(value.latitude, value.longitude),
          14.5,
        );
      },
      onCheckpoint: (validation) {
        if (!mounted) return;
        setState(() {
          lastCheckpoint = validation;
          gpsReached.add(validation.checkpoint.id);
        });
        final currentPosition = position;
        if (currentPosition != null) {
          unawaited(_verifyReward(validation, currentPosition));
        }
      },
    );

    setState(() {
      tracking = true;
      status = 'GPS tracking active';
    });
  }

  Future<void> _verifyReward(
    CheckpointValidation validation,
    Position currentPosition,
  ) async {
    final checkpoint = validation.checkpoint;
    if (!attemptedVerification.add(checkpoint.id)) return;
    setState(() => pendingVerification.add(checkpoint.id));
    try {
      final verified = await rewardService.verify(
        checkpoint: checkpoint,
        position: currentPosition,
      );
      if (!mounted) return;
      if (verified) setState(() => verifiedRewards.add(checkpoint.id));
    } catch (_) {
      attemptedVerification.remove(checkpoint.id);
    } finally {
      if (mounted) setState(() => pendingVerification.remove(checkpoint.id));
    }
  }

  @override
  void dispose() {
    unawaited(tracker.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = position == null
        ? const LatLng(27.7172, 85.3240)
        : LatLng(position!.latitude, position!.longitude);

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: current,
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: ApiConstants.osmTiles,
              userAgentPackageName: 'com.feelit.official',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: current,
                  width: 56,
                  height: 56,
                  child: const _RiderMarker(),
                ),
                ...checkpoints.map(
                  (checkpoint) => Marker(
                    point: LatLng(checkpoint.latitude, checkpoint.longitude),
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.local_cafe,
                      size: 34,
                      color: Color(0xFFFFB703),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: GlassCard(
            child: Row(
              children: [
                const Icon(Icons.radar, color: Color(0xFF00F5D4)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    status,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: toggleTracking,
                  icon: Icon(
                    tracking ? Icons.stop_circle : Icons.my_location,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 12,
          height: 136,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: checkpoints.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final checkpoint = checkpoints[index];
              final verified = verifiedRewards.contains(checkpoint.id);
              final reached = gpsReached.contains(checkpoint.id);
              final verifying = pendingVerification.contains(checkpoint.id);
              final food = checkpoint.rewardId == 'momo-01'
                  ? 'Steamed momos'
                  : 'Himalayan milk tea';
              final state = verified
                  ? 'Reward verified'
                  : verifying
                      ? 'GPS reached · verifying'
                      : reached
                          ? 'GPS reached · server pending'
                          : 'Locked · ride to checkpoint';

              return SizedBox(
                width: 238,
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            verified ? Icons.lock_open : Icons.lock_outline,
                            color: const Color(0xFFFFB703),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              checkpoint.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      verified
                          ? Text(food, style: const TextStyle(fontSize: 18))
                          : ImageFiltered(
                              imageFilter:
                                  ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Text(food,
                                  style: const TextStyle(fontSize: 18)),
                            ),
                      const SizedBox(height: 3),
                      Text(state,
                          style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RiderMarker extends StatelessWidget {
  const _RiderMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF00F5D4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x6600F5D4),
            blurRadius: 18,
            spreadRadius: 4,
          ),
        ],
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: const Icon(
        Icons.two_wheeler,
        color: Color(0xFF07110F),
      ),
    );
  }
}
