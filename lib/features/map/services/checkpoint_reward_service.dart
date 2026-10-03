import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/checkpoint.dart';

class CheckpointRewardService {
  Future<bool> verify({
    required Checkpoint checkpoint,
    required Position position,
  }) async {
    final response = await Supabase.instance.client.functions.invoke(
      'verify-checkpoint',
      body: {
        'checkpoint_id': checkpoint.id,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy_meters': position.accuracy,
      },
    );
    final data = response.data;
    return data is Map && data['verified'] == true;
  }
}
