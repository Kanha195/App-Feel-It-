class Motorcycle {
  const Motorcycle({
    required this.id,
    required this.manufacturer,
    required this.model,
    required this.displacementCc,
    required this.year,
    this.nickname,
  });

  final String id;
  final String manufacturer;
  final String model;
  final int displacementCc;
  final int year;
  final String? nickname;

  String get displayName {
    final cc = displacementCc > 0 ? ' $displacementCc cc' : '';
    return '$manufacturer $model$cc';
  }

  Motorcycle copyWith({
    String? id,
    String? manufacturer,
    String? model,
    int? displacementCc,
    int? year,
    String? nickname,
  }) {
    return Motorcycle(
      id: id ?? this.id,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      displacementCc: displacementCc ?? this.displacementCc,
      year: year ?? this.year,
      nickname: nickname ?? this.nickname,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'manufacturer': manufacturer,
        'model': model,
        'displacementCc': displacementCc,
        'year': year,
        'nickname': nickname,
      };

  factory Motorcycle.fromJson(Map<String, dynamic> json) {
    return Motorcycle(
      id: json['id'] as String,
      manufacturer: json['manufacturer'] as String,
      model: json['model'] as String,
      displacementCc: (json['displacementCc'] as num?)?.toInt() ?? 0,
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      nickname: json['nickname'] as String?,
    );
  }
}
