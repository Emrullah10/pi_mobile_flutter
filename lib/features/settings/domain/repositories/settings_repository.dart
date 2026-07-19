/// Abstraction over the Pi backend's settings/microphone/reboot endpoints.
abstract class SettingsRepository {
  Future<Map<String, dynamic>> getSettings();
  Future<bool> saveSettings(Map<String, dynamic> settings);
  Future<List<Map<String, String>>> getMicrophones();
  Future<void> rebootPi();
}
