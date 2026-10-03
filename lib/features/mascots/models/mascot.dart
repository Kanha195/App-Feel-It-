enum MascotType { dowie, snowie }

enum MascotMood { happy, cold, rainy, excited, sleepy }

class Mascot {
  const Mascot({
    required this.type,
    this.mood = MascotMood.happy,
    this.outfitId = 'default',
  });

  final MascotType type;
  final MascotMood mood;
  final String outfitId;

  String get name => type == MascotType.dowie ? 'Dowie' : 'Snowie';

  Mascot copyWith({
    MascotMood? mood,
    String? outfitId,
  }) {
    return Mascot(
      type: type,
      mood: mood ?? this.mood,
      outfitId: outfitId ?? this.outfitId,
    );
  }
}
