import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../settings/domain/entities/system_info.dart';
import '../domain/entities/system_status.dart';

/// Wraps the Pi backend endpoints needed by the dashboard: status, system
/// info, and the transcription/analysis process-status feed.
class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<SystemStatus> getStatus() async {
    try {
      final json = await _apiClient.get(ApiConstants.status);
      return SystemStatus.fromJson(json);
    } catch (_) {
      return SystemStatus.offline();
    }
  }

  Future<SystemInfo> getSystemInfo() async {
    try {
      final json = await _apiClient.get(ApiConstants.system);
      return SystemInfo.fromJson(json);
    } catch (_) {
      return SystemInfo.empty();
    }
  }

  Future<Map<String, dynamic>> getProcessStatus() async {
    try {
      return await _apiClient.get(ApiConstants.processStatus);
    } catch (_) {
      return {};
    }
  }
}
