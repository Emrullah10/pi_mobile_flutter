import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final ApiClient _apiClient;

  SettingsRepositoryImpl({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<Map<String, dynamic>> getSettings() async {
    try {
      return await _apiClient.get(ApiConstants.settings);
    } catch (_) {
      return {};
    }
  }

  @override
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      await _apiClient.post(ApiConstants.settings, body: settings);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<Map<String, String>>> getMicrophones() async {
    try {
      final json = await _apiClient.get(ApiConstants.microphones);
      final list = json['microphones'] as List<dynamic>? ?? [];
      return list.map((e) => {
        'id': (e['id'] as String?) ?? '',
        'name': (e['name'] as String?) ?? '',
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> rebootPi() async {
    await _apiClient.post(ApiConstants.reboot);
  }
}
