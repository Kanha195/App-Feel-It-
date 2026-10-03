import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../../core/services/location_service.dart';
import '../models/checkpoint.dart';
import 'checkpoint_validator.dart';

class GpsTracker {
  GpsTracker({
    LocationService? locationService,
    CheckpointValidator? validator,
  })  : _locationService = locationService ?? LocationService(),
        _validator = validator ?? CheckpointValidator();

  final LocationService _locationService;
  final CheckpointValidator _validator;

  StreamSubscription<Position>? _subscription;

  void start({
    required List<Checkpoint> checkpoints,
    required void Function(Position position) onPosition,
    required void Function(CheckpointValidation validation) onCheckpoint,
  }) {
    _subscription?.cancel();

    _subscription = _locationService.stream().listen((position) {
      onPosition(position);

      for (final checkpoint in checkpoints) {
        final result = _validator.validate(
          latitude: position.latitude,
          longitude: position.longitude,
          checkpoint: checkpoint,
        );
        if (result.insideRadius) {
          onCheckpoint(result);
        }
      }
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
