import 'package:flutter_test/flutter_test.dart';
import 'package:feel_it_official/features/map/models/checkpoint.dart';
import 'package:feel_it_official/features/map/services/checkpoint_validator.dart';

void main() {
  test('checkpoint unlocks inside configured radius', () {
    const checkpoint = Checkpoint(
      id: 'test',
      name: 'Test stop',
      latitude: 27.7172,
      longitude: 85.3240,
      unlockRadiusMeters: 100,
      rewardId: 'reward',
    );

    final result = CheckpointValidator().validate(
      latitude: 27.7172,
      longitude: 85.3240,
      checkpoint: checkpoint,
    );

    expect(result.insideRadius, isTrue);
    expect(result.distanceMeters, lessThan(1));
  });
}
