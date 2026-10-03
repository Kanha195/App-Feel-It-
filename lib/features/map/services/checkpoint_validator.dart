import '../../../shared/utils/geo_utils.dart';
import '../models/checkpoint.dart';

class CheckpointValidation {
  const CheckpointValidation({
    required this.checkpoint,
    required this.distanceMeters,
    required this.insideRadius,
  });

  final Checkpoint checkpoint;
  final double distanceMeters;
  final bool insideRadius;
}

class CheckpointValidator {
  CheckpointValidation validate({
    required double latitude,
    required double longitude,
    required Checkpoint checkpoint,
  }) {
    final distance = distanceMeters(
      latitude,
      longitude,
      checkpoint.latitude,
      checkpoint.longitude,
    );

    return CheckpointValidation(
      checkpoint: checkpoint,
      distanceMeters: distance,
      insideRadius: distance <= checkpoint.unlockRadiusMeters,
    );
  }
}
