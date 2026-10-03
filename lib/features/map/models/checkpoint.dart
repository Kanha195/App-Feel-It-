class Checkpoint {
  const Checkpoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.unlockRadiusMeters,
    required this.rewardId,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double unlockRadiusMeters;
  final String rewardId;
}
