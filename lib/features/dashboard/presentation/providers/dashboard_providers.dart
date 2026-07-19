import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../history/presentation/providers/history_providers.dart';
import '../../../settings/domain/entities/system_info.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/dashboard_repository.dart';
import '../../domain/entities/system_status.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

/// Polls GET /api/status every 5s.
class SystemStatusNotifier extends Notifier<SystemStatus> {
  Timer? _pollTimer;
  DashboardRepository get _repo => ref.read(dashboardRepositoryProvider);

  @override
  SystemStatus build() {
    _startPolling();
    ref.onDispose(() => _pollTimer?.cancel());
    // Kick off an initial refresh.
    Future.microtask(refreshStatus);
    return SystemStatus.offline();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => refreshStatus());
  }

  Future<void> refreshStatus() async {
    final newStatus = await _repo.getStatus();
    state = newStatus;
  }

  /// Optimistically reflects a local recording-state change (phone mic path)
  /// without waiting for the next poll tick.
  void setRecording(bool isRecording) {
    state = SystemStatus(online: state.online, isRecording: isRecording, timestamp: DateTime.now());
  }
}

final systemStatusProvider = NotifierProvider<SystemStatusNotifier, SystemStatus>(SystemStatusNotifier.new);

final isOnlineProvider = Provider<bool>((ref) => ref.watch(systemStatusProvider).online);

/// Polls GET /api/system every 30s.
class SystemInfoNotifier extends Notifier<SystemInfo> {
  Timer? _pollTimer;
  DashboardRepository get _repo => ref.read(dashboardRepositoryProvider);

  @override
  SystemInfo build() {
    _startPolling();
    ref.onDispose(() => _pollTimer?.cancel());
    Future.microtask(refreshSystemInfo);
    return SystemInfo.empty();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => refreshSystemInfo());
  }

  Future<void> refreshSystemInfo() async {
    state = await _repo.getSystemInfo();
  }
}

final systemInfoProvider = NotifierProvider<SystemInfoNotifier, SystemInfo>(SystemInfoNotifier.new);

class ProcessStatusState {
  final String state;
  final String filename;
  final String step;
  final double progress;

  const ProcessStatusState({
    this.state = 'idle',
    this.filename = '',
    this.step = '',
    this.progress = 0.0,
  });

  ProcessStatusState copyWith({String? state, String? filename, String? step, double? progress}) {
    return ProcessStatusState(
      state: state ?? this.state,
      filename: filename ?? this.filename,
      step: step ?? this.step,
      progress: progress ?? this.progress,
    );
  }
}

/// Polls GET /api/process-status every 3s while a transcription/analysis job
/// is active. Stops polling and refreshes history once the job is done or errors.
class ProcessStatusNotifier extends Notifier<ProcessStatusState> {
  Timer? _pollTimer;
  DashboardRepository get _repo => ref.read(dashboardRepositoryProvider);

  @override
  ProcessStatusState build() {
    ref.onDispose(() => _pollTimer?.cancel());
    return const ProcessStatusState();
  }

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await refreshProcessStatus();
      if (state.state == 'done' || state.state == 'error') {
        _pollTimer?.cancel();
        await ref.read(historyProvider.notifier).refreshHistory();
      }
    });
  }

  Future<void> refreshProcessStatus() async {
    final data = await _repo.getProcessStatus();
    if (data.isNotEmpty) {
      final newState = data['state'] ?? 'idle';
      final newStep = data['step'] ?? '';
      final newProgress = (data['progress'] as num?)?.toDouble() ?? 0.0;
      if (newState != state.state || newStep != state.step || newProgress != state.progress) {
        state = state.copyWith(
          state: newState,
          filename: data['filename'] ?? '',
          step: newStep,
          progress: newProgress,
        );
      }
    }
  }

  void setUploading() {
    state = state.copyWith(state: 'processing', step: 'upload', progress: 0);
  }

  void setUploadFailed() {
    state = state.copyWith(state: 'error', step: 'upload_failed');
  }
}

final processStatusProvider = NotifierProvider<ProcessStatusNotifier, ProcessStatusState>(ProcessStatusNotifier.new);

/// Re-fetches status/history/system-info/settings/microphones together.
/// Used after the server address changes to re-sync all app state.
Future<void> reconnectAll(WidgetRef ref) async {
  await Future.wait([
    ref.read(systemStatusProvider.notifier).refreshStatus(),
    ref.read(historyProvider.notifier).refreshHistory(),
    ref.read(systemInfoProvider.notifier).refreshSystemInfo(),
    ref.read(settingsProvider.notifier).refreshSettings(),
    ref.read(microphoneListProvider.notifier).refreshMicrophones(),
  ]);
}
