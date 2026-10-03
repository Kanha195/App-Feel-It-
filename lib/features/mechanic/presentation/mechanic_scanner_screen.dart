import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../../../core/widgets/glass_card.dart';
import '../services/diagnostic_service.dart';

class MechanicScannerScreen extends StatefulWidget {
  const MechanicScannerScreen({super.key});

  @override
  State<MechanicScannerScreen> createState() => _MechanicScannerScreenState();
}

class _MechanicScannerScreenState extends State<MechanicScannerScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final DiagnosticService _diagnostics = DiagnosticService();
  final List<double> _levels = List<double>.filled(36, 0);
  CameraController? _camera;
  StreamSubscription<Uint8List>? _audioSubscription;
  XFile? _capturedImage;
  double _audioRms = 0;
  bool _recording = false;
  bool _loadingCamera = false;
  bool _diagnosing = false;
  String? _cameraError;
  String? _suggestion;
  String? _diagnosticError;

  Future<void> _openCamera() async {
    if (_camera?.value.isInitialized == true || _loadingCamera) return;
    setState(() {
      _loadingCamera = true;
      _cameraError = null;
    });
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('no_camera', 'No camera available.');
      }
      final camera = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await camera.initialize();
      if (!mounted) {
        await camera.dispose();
        return;
      }
      setState(() => _camera = camera);
    } on CameraException catch (error) {
      if (mounted) {
        setState(() => _cameraError = error.description ?? error.code);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _cameraError = 'Camera is unavailable on this device.');
      }
    } finally {
      if (mounted) setState(() => _loadingCamera = false);
    }
  }

  Future<void> _captureImage() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) {
      await _openCamera();
      return;
    }
    try {
      final image = await camera.takePicture();
      if (mounted) {
        setState(() {
          _capturedImage = image;
          _suggestion = null;
          _diagnosticError = null;
        });
      }
    } on CameraException catch (error) {
      if (mounted) {
        setState(() => _cameraError = error.description ?? error.code);
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_recording) {
      await _audioSubscription?.cancel();
      await _recorder.stop();
      if (mounted) setState(() => _recording = false);
      return;
    }

    try {
      if (!await _recorder.hasPermission()) {
        setState(() => _diagnosticError = 'Microphone permission is required.');
        return;
      }
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 44100,
          numChannels: 1,
        ),
      );
      _audioSubscription = stream.listen(_recordSamples);
      if (mounted) setState(() => _recording = true);
    } catch (_) {
      if (mounted) {
        setState(() => _diagnosticError = 'Microphone capture is unavailable.');
      }
    }
  }

  void _recordSamples(Uint8List bytes) {
    final count = bytes.length ~/ 2;
    if (count == 0) return;
    final samples = bytes.buffer.asInt16List(bytes.offsetInBytes, count);
    var sumSquares = 0.0;
    for (final sample in samples) {
      final normalized = sample / 32768.0;
      sumSquares += normalized * normalized;
    }
    final rms = math.sqrt(sumSquares / count);
    if (!mounted) return;
    setState(() {
      _audioRms = rms;
      _levels.removeAt(0);
      _levels.add(rms.clamp(0.02, 1.0));
    });
  }

  Future<void> _requestDiagnosis() async {
    setState(() {
      _diagnosing = true;
      _diagnosticError = null;
      _suggestion = null;
    });
    try {
      final suggestion = await _diagnostics.diagnose(
        image: _capturedImage,
        audioRms: _audioRms,
      );
      if (mounted) setState(() => _suggestion = suggestion);
    } catch (_) {
      if (mounted) {
        setState(() {
          _diagnosticError =
              'Diagnosis service is unavailable. Check the mechanic-diagnosis '
              'Supabase Edge Function and try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _diagnosing = false);
    }
  }

  @override
  void dispose() {
    unawaited(_audioSubscription?.cancel());
    unawaited(_recorder.dispose());
    unawaited(_camera?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Mechanic scanner',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        const Text('Capture a part and listen for unusual engine vibration.'),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: _camera?.value.isInitialized == true
                ? CameraPreview(_camera!)
                : ColoredBox(
                    color: const Color(0xFF111827),
                    child: Center(
                      child: _loadingCamera
                          ? const CircularProgressIndicator()
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _capturedImage == null
                                      ? Icons.camera_alt_outlined
                                      : Icons.check_circle_outline,
                                  size: 48,
                                  color: const Color(0xFF00F5D4),
                                ),
                                const SizedBox(height: 8),
                                Text(_cameraError ??
                                    (_capturedImage == null
                                        ? 'Camera ready when you are'
                                        : 'Image captured')),
                              ],
                            ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _loadingCamera ? null : _openCamera,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Open camera'),
            ),
            FilledButton.tonalIcon(
              onPressed: _captureImage,
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('Capture part'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.graphic_eq, color: Color(0xFF00F5D4)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Engine audio',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  TextButton.icon(
                    onPressed: _toggleRecording,
                    icon: Icon(_recording ? Icons.stop : Icons.mic),
                    label: Text(_recording ? 'Stop' : 'Listen'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 56,
                width: double.infinity,
                child: CustomPaint(painter: _WaveformPainter(List.of(_levels))),
              ),
              Text(_recording
                  ? 'Live RMS ${_audioRms.toStringAsFixed(3)}'
                  : 'Mic paused'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed:
              _diagnosing || _capturedImage == null ? null : _requestDiagnosis,
          icon: _diagnosing
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome),
          label: const Text('Request AI diagnosis'),
        ),
        if (_diagnosticError != null || _suggestion != null) ...[
          const SizedBox(height: 12),
          GlassCard(
            child: Text(
              _suggestion ?? _diagnosticError!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter(this.levels);

  final List<double> levels;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F5D4)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final step = size.width / levels.length;
    for (var i = 0; i < levels.length; i++) {
      final height = math.max(3.0, levels[i] * size.height);
      final x = i * step + step / 2;
      canvas.drawLine(
        Offset(x, (size.height - height) / 2),
        Offset(x, (size.height + height) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => true;
}
