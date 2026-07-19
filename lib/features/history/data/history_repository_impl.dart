import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../domain/entities/analysis_result.dart';
import '../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final ApiClient _apiClient;

  HistoryRepositoryImpl({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<AnalysisResult>> getHistory() async {
    try {
      final list = await _apiClient.getList(ApiConstants.history);
      return list
          .map((e) => AnalysisResult.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return [];
    }
  }
}
