enum WeatherCondition {
  clear,
  partlyCloudy,
  cloudy,
  rain,
  snow,
  storm,
  unknown,
}

class WeatherState {
  const WeatherState({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.condition,
  });

  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final WeatherCondition condition;

  bool get needsWarmClothes => temperature < 12;
  bool get needsRainGear =>
      condition == WeatherCondition.rain ||
      condition == WeatherCondition.storm;
  bool get needsSnowGear => condition == WeatherCondition.snow;

  String get label => switch (condition) {
        WeatherCondition.clear => 'Clear',
        WeatherCondition.partlyCloudy => 'Partly cloudy',
        WeatherCondition.cloudy => 'Cloudy',
        WeatherCondition.rain => 'Rain',
        WeatherCondition.snow => 'Snow',
        WeatherCondition.storm => 'Storm',
        WeatherCondition.unknown => 'Unknown',
      };

  factory WeatherState.fromOpenMeteo(Map<String, dynamic> json) {
    final code = (json['weather_code'] as num?)?.toInt() ?? -1;
    return WeatherState(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      weatherCode: code,
      condition: conditionFromCode(code),
    );
  }

  static WeatherCondition conditionFromCode(int code) {
    if (code == 0) return WeatherCondition.clear;
    if (code <= 3) return WeatherCondition.partlyCloudy;
    if (code >= 51 && code <= 67) return WeatherCondition.rain;
    if (code >= 71 && code <= 77) return WeatherCondition.snow;
    if (code >= 80 && code <= 82) return WeatherCondition.rain;
    if (code >= 95) return WeatherCondition.storm;
    return WeatherCondition.unknown;
  }
}
