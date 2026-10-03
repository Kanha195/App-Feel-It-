import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiagnosticService {
  Future<String> diagnose(
      {required XFile? image, required double audioRms}) async {
    if (image == null) {
      throw ArgumentError(
          'Capture a bike-part image before requesting diagnosis.');
    }

    final bytes = await image.readAsBytes();
    final response = await Supabase.instance.client.functions.invoke(
      'mechanic-diagnosis',
      body: {
        'image_base64': base64Encode(bytes),
        'image_mime_type': image.mimeType ?? 'image/jpeg',
        'audio_rms': audioRms,
      },
    );

    final data = response.data;
    if (data is Map && data['suggestion'] is String) {
      return data['suggestion'] as String;
    }
    throw const FormatException('The mechanic service returned no suggestion.');
  }
}
