import '../entities/analysis_result.dart';

abstract class HistoryRepository {
  Future<List<AnalysisResult>> getHistory();
}
