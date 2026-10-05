import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/location_service.dart';
import '../../../core/services/weather_service.dart';
import '../../weather/models/weather_state.dart';

class VirtualHomeWeatherSnapshot {
  const VirtualHomeWeatherSnapshot({
    required this.weather,
    required this.location,
    this.message,
  });

  final WeatherState? weather;
  final String location;
  final String? message;
}

class VirtualHomeLocationController extends Notifier<bool> {
  @override
  bool build() => false;

  void useCurrentLocation(bool enabled) => state = enabled;
}

final virtualHomeUseCurrentLocationProvider =
    NotifierProvider<VirtualHomeLocationController, bool>(
  VirtualHomeLocationController.new,
);

final virtualHomeWeatherProvider =
    StreamProvider.autoDispose<VirtualHomeWeatherSnapshot>((ref) async* {
  final service = WeatherService();
  final locationService = LocationService();
  final useCurrentLocation = ref.watch(virtualHomeUseCurrentLocationProvider);

  while (true) {
    var latitude = 27.7172;
    var longitude = 85.3240;
    var location = 'Kathmandu, Nepal';
    String? message;

    if (useCurrentLocation) {
      try {
        final position = await locationService.currentPosition();
        if (position == null) {
          message = 'Location unavailable; showing Kathmandu weather.';
        } else {
          latitude = position.latitude;
          longitude = position.longitude;
          location = 'Your location';
        }
      } catch (_) {
        message = 'Location unavailable; showing Kathmandu weather.';
      }
    }

    try {
      final weather = await service.fetch(
        latitude: latitude,
        longitude: longitude,
      );
      yield VirtualHomeWeatherSnapshot(
        weather: weather,
        location: location,
        message: message,
      );
    } catch (_) {
      yield VirtualHomeWeatherSnapshot(
        weather: null,
        location: location,
        message: 'Live weather unavailable; retrying shortly.',
      );
    }

    await Future<void>.delayed(const Duration(minutes: 5));
  }
});

class MascotCareStats {
  const MascotCareStats({
    this.fullness = 68,
    this.energy = 74,
    this.cleanliness = 82,
    this.joy = 78,
  });

  final int fullness;
  final int energy;
  final int cleanliness;
  final int joy;

  MascotCareStats copyWith({
    int? fullness,
    int? energy,
    int? cleanliness,
    int? joy,
  }) =>
      MascotCareStats(
        fullness: fullness ?? this.fullness,
        energy: energy ?? this.energy,
        cleanliness: cleanliness ?? this.cleanliness,
        joy: joy ?? this.joy,
      );
}

class MascotCareController extends Notifier<Map<String, MascotCareStats>> {
  @override
  Map<String, MascotCareStats> build() => const {
        'dowie': MascotCareStats(),
        'snowie': MascotCareStats(),
      };

  void feed(String mascot) => _update(
        mascot,
        (stats) => stats.copyWith(
          fullness: (stats.fullness + 20).clamp(0, 100).toInt(),
          joy: (stats.joy + 5).clamp(0, 100).toInt(),
        ),
      );

  void rest(String mascot) => _update(
        mascot,
        (stats) => stats.copyWith(
          energy: (stats.energy + 20).clamp(0, 100).toInt(),
        ),
      );

  void groom(String mascot) => _update(
        mascot,
        (stats) => stats.copyWith(
          cleanliness: (stats.cleanliness + 20).clamp(0, 100).toInt(),
          joy: (stats.joy + 5).clamp(0, 100).toInt(),
        ),
      );

  void play(String mascot) => _update(
        mascot,
        (stats) => stats.copyWith(
          joy: (stats.joy + 12).clamp(0, 100).toInt(),
          energy: (stats.energy - 5).clamp(0, 100).toInt(),
        ),
      );

  void _update(String mascot, MascotCareStats Function(MascotCareStats) update) {
    final current = state[mascot] ?? const MascotCareStats();
    state = {...state, mascot: update(current)};
  }
}

final mascotCareProvider =
    NotifierProvider<MascotCareController, Map<String, MascotCareStats>>(
  MascotCareController.new,
);
