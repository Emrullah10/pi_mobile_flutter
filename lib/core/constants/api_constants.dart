import 'server_config.dart';

/// API Constants for Raspberry Pi Backend
class ApiConstants {
  ApiConstants._();

  static String get baseUrl => ServerConfig.baseUrl;

  // Endpoints
  static const String status = '/api/status';
  static const String recordStart = '/api/record/start';
  static const String recordStop = '/api/record/stop';
  static const String history = '/api/history';
  static const String system = '/api/system';
  static const String settings = '/api/settings';
  static const String processStatus = '/api/process-status';
  static const String reboot = '/api/reboot';
  static const String microphones = '/api/microphones';
  static const String upload = '/api/upload';
  static String audioFile(String filename) => '/api/audio/$filename';
}
