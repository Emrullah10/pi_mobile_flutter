import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/history_repository_impl.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/repositories/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl();
});

class HistoryNotifier extends AsyncNotifier<List<AnalysisResult>> {
  HistoryRepository get _repo => ref.read(historyRepositoryProvider);

  @override
  Future<List<AnalysisResult>> build() async {
    return _repo.getHistory();
  }

  Future<void> refreshHistory() async {
    state = const AsyncLoading();
    state = AsyncData(await _repo.getHistory());
  }
}

final historyProvider = AsyncNotifierProvider<HistoryNotifier, List<AnalysisResult>>(HistoryNotifier.new);
