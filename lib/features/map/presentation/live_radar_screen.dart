import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/glass_card.dart';
import '../models/checkpoint.dart';
import '../services/checkpoint_validator.dart';
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

  Position? position;
  String status = 'GPS waiting';
  CheckpointValidation? lastCheckpoint;
  bool tracking = false;

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
        setState(() => lastCheckpoint = validation);
      },
    );

    setState(() {
      tracking = true;
      status = 'GPS tracking active';
    });
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
        if (lastCheckpoint != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: GlassCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.workspace_premium,
                  color: Color(0xFFFFB703),
                  size: 34,
                ),
                title: Text(
                  lastCheckpoint!.checkpoint.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  'Client detected inside ${lastCheckpoint!.checkpoint.unlockRadiusMeters.toStringAsFixed(0)}m reward radius.',
                ),
              ),
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
