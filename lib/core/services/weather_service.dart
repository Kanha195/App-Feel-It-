import 'package:dio/dio.dart';

import '../../features/weather/models/weather_state.dart';
import '../constants/api_constants.dart';

class WeatherService {
  WeatherService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<WeatherState> fetch({
    double latitude = 27.7172,
    double longitude = 85.3240,
  }) async {
    final response = await _dio.get(
      ApiConstants.openMeteo,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'current': 'temperature_2m,weather_code,wind_speed_10m',
        'timezone': 'auto',
      },
    );

    final current = Map<String, dynamic>.from(response.data['current'] as Map);

    return WeatherState.fromOpenMeteo(current);
  }
}
