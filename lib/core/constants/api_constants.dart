/// API Constants for Raspberry Pi Backend
class ApiConstants {
  ApiConstants._();

  // TODO: Raspberry Pi'nin gerçek IP adresi ile değiştirin
  static const String baseUrl = 'http://192.168.1.42:3000';

  // Endpoints
  static const String status = '/api/status';
  static const String recordStart = '/api/record/start';
  static const String recordStop = '/api/record/stop';
  static const String history = '/api/history';
  static const String system = '/api/system';
  static const String settings = '/api/settings';
  static const String processStatus = '/api/process-status';
  static const String reboot = '/api/reboot';
}
