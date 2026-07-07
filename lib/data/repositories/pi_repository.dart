import '../../core/constants/api_constants.dart';
import '../models/system_status.dart';
import '../models/analysis_result.dart';
import '../models/system_info.dart';
import '../services/api_service.dart';

/// Repository for all Raspberry Pi backend interactions
class PiRepository {
  final ApiService _apiService;

  PiRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get current system status (online, recording state)
  Future<SystemStatus> getStatus() async {
    try {
      final json = await _apiService.get(ApiConstants.status);
      return SystemStatus.fromJson(json);
    } catch (_) {
      return SystemStatus.offline();
    }
  }

  /// Start audio recording on Raspberry Pi
  Future<String?> startRecording() async {
    try {
      final json = await _apiService.post(ApiConstants.recordStart);
      return json['file'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Stop current recording
  Future<bool> stopRecording({String? customName}) async {
    try {
      await _apiService.post(ApiConstants.recordStop,
          body: customName != null ? {'customName': customName} : null);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get analysis history
  Future<List<AnalysisResult>> getHistory() async {
    try {
      final list = await _apiService.getList(ApiConstants.history);
      return list
          .map((e) => AnalysisResult.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return [];
    }
  }

  Future<SystemInfo> getSystemInfo() async {
    try {
      final json = await _apiService.get(ApiConstants.system);
      return SystemInfo.fromJson(json);
    } catch (_) {
      return SystemInfo.empty();
    }
  }

  Future<Map<String, dynamic>> getProcessStatus() async {
    try {
      return await _apiService.get(ApiConstants.processStatus);
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      return await _apiService.get(ApiConstants.settings);
    } catch (_) {
      return {};
    }
  }

  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      await _apiService.post(ApiConstants.settings, body: settings);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, String>>> getMicrophones() async {
    try {
      final json = await _apiService.get(ApiConstants.microphones);
      final list = json['microphones'] as List<dynamic>? ?? [];
      return list.map((e) => {
        'id': (e['id'] as String?) ?? '',
        'name': (e['name'] as String?) ?? '',
      }).toList();
    } catch (_) {
      return [];
    }
  }

  String getAudioUrl(String filename) =>
      '${ApiConstants.baseUrl}${ApiConstants.audioFile(filename)}';

  Future<void> rebootPi() async {
    await _apiService.post(ApiConstants.reboot);
  }

  void dispose() {
    _apiService.dispose();
  }
}
