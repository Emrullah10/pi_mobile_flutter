import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioPlayerService {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isOpen = false;
  StreamSubscription? _progressSub;
  String? _cachedUrl;
  String? _cachedPath;

  Future<void> open() async {
    if (!_isOpen) {
      await _player.openPlayer();
      await _player.setSubscriptionDuration(const Duration(milliseconds: 200));
      _isOpen = true;
    }
  }

  /// Uzak WAV'ı telefonun geçici klasörüne indirir, lokal yolu döner.
  /// Android MediaPlayer uzak WAV streaming'de seek yapamayıp
  /// IOException/Error(1,-2147483648) veriyordu; lokal dosya bu sorunu çözer.
  Future<String> _downloadToCache(String url) async {
    if (_cachedUrl == url && _cachedPath != null && File(_cachedPath!).existsSync()) {
      return _cachedPath!;
    }
    // Audio endpoint JWT ile korumalı; token'ı SharedPreferences'tan al.
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final resp = await http.get(
      Uri.parse(url),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    if (resp.statusCode != 200) {
      throw Exception('Ses indirilemedi: HTTP ${resp.statusCode}');
    }
    // Backend 404'te bile bazen JSON döndürebilir; gerçek WAV mı doğrula.
    // WAV dosyaları 'RIFF' (0x52 49 46 46) ile başlar.
    final b = resp.bodyBytes;
    if (b.length < 12 || b[0] != 0x52 || b[1] != 0x49 || b[2] != 0x46 || b[3] != 0x46) {
      throw Exception('Ses dosyası bulunamadı veya geçersiz.');
    }
    final dir = await getTemporaryDirectory();
    final safeName = url.hashCode.toRadixString(16);
    final file = File('${dir.path}/audio_$safeName.wav');
    await file.writeAsBytes(resp.bodyBytes);
    _cachedUrl = url;
    _cachedPath = file.path;
    return file.path;
  }

  Future<void> play(String url, {void Function(Duration pos, Duration dur)? onProgress, VoidCallback? onFinished}) async {
    await open();
    // Önce lokale indir (seek sorununu ve gecikmeyi çözer)
    final localPath = await _downloadToCache(url);
    await _progressSub?.cancel();
    _progressSub = _player.onProgress?.listen((e) {
      onProgress?.call(e.position, e.duration);
    });
    await _player.startPlayer(
      fromURI: localPath,
      codec: Codec.pcm16WAV,
      whenFinished: () {
        onFinished?.call();
        onProgress?.call(Duration.zero, Duration.zero);
      },
    );
  }

  Future<void> pause() async => _player.pausePlayer();
  Future<void> resume() async => _player.resumePlayer();
  Future<void> stop() async {
    await _progressSub?.cancel();
    _progressSub = null;
    await _player.stopPlayer();
  }

  bool get isPlaying => _player.isPlaying;
  bool get isPaused => _player.isPaused;

  Future<void> dispose() async {
    await _progressSub?.cancel();
    if (_isOpen) {
      await _player.closePlayer();
      _isOpen = false;
    }
  }
}
