import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class PhoneRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;
  String? _currentPath;

  Future<bool> startRecording() async {
    try {
      if (!_isInitialized) {
        await _recorder.openRecorder();
        _isInitialized = true;
      }
      final dir = await getTemporaryDirectory();
      _currentPath = '${dir.path}/phone_rec_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _recorder.startRecorder(
        toFile: _currentPath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<File?> stopRecording() async {
    try {
      await _recorder.stopRecorder();
      if (_currentPath == null) return null;
      return File(_currentPath!);
    } catch (_) {
      return null;
    }
  }

  Future<bool> uploadRecording(File file, {String? customName}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.upload}');
      final request = http.MultipartRequest('POST', uri);
      final filename = customName != null
          ? '${customName.replaceAll(RegExp(r'[^a-zA-Z0-9ğüşıöçĞÜŞİÖÇ_\-]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.wav'
          : 'phone_${DateTime.now().millisecondsSinceEpoch}.wav';
      request.files.add(await http.MultipartFile.fromPath('audio', file.path, filename: filename));
      if (customName != null) request.fields['customName'] = customName;
      final response = await request.send().timeout(const Duration(seconds: 30));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isRecording() async => _recorder.isRecording;

  void dispose() {
    _recorder.closeRecorder();
  }
}
