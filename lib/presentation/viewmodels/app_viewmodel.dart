import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/system_status.dart';
import '../../data/models/analysis_result.dart';
import '../../data/models/system_info.dart';
import '../../data/repositories/pi_repository.dart';

/// Main app-wide state manager
/// Handles recording state, system status, and history
class AppViewModel extends ChangeNotifier {
  final PiRepository _repository;

  // ─── State ───
  SystemStatus _status = SystemStatus.offline();
  List<AnalysisResult> _history = [];
  SystemInfo _systemInfo = SystemInfo.empty();
  bool _isLoading = false;
  String? _error;

  // ─── Settings ───
  String settingsEmail = '';
  String settingsModel = 'medium';
  String settingsLanguage = 'auto';

  // ─── Locale ───
  bool isTurkish = true;
  AppLocalizations get l10n => AppLocalizations(isTurkish: isTurkish);

  void toggleLocale() {
    isTurkish = !isTurkish;
    notifyListeners();
  }

  // ─── Process Status ───
  String processState = 'idle';
  String processFilename = '';
  String processStep = '';
  double processProgress = 0.0;

  // ─── Recording Timer ───
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  Stopwatch? _stopwatch;

  // ─── Polling ───
  Timer? _statusPollTimer;
  Timer? _processPollTimer;
  Timer? _systemInfoPollTimer;

  AppViewModel({PiRepository? repository})
      : _repository = repository ?? PiRepository() {
    _init();
  }

  // ─── Getters ───
  SystemStatus get status => _status;
  List<AnalysisResult> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isRecording => _status.isRecording;
  bool get isOnline => _status.online;
  Duration get recordingDuration => _recordingDuration;
  SystemInfo get systemInfo => _systemInfo;

  // ─── Initialization ───
  Future<void> _init() async {
    await Future.wait([refreshStatus(), refreshHistory(), refreshSystemInfo(), refreshSettings()]);
    _startStatusPolling();
    _startSystemInfoPolling();
  }

  void _startStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => refreshStatus(),
    );
  }

  void _startSystemInfoPolling() {
    _systemInfoPollTimer?.cancel();
    _systemInfoPollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => refreshSystemInfo(),
    );
  }

  // ─── Status ───
  Future<void> refreshStatus() async {
    try {
      final newStatus = await _repository.getStatus();
      if (newStatus.online != _status.online || newStatus.isRecording != _status.isRecording) {
        _status = newStatus;
        _error = null;
        notifyListeners();
      } else {
        _status = newStatus;
      }
    } catch (e) {
      _status = SystemStatus.offline();
      _error = e.toString();
      notifyListeners();
    }
  }

  // ─── System Info ───
  Future<void> refreshSystemInfo() async {
    _systemInfo = await _repository.getSystemInfo();
    notifyListeners();
  }

  // ─── History ───
  Future<void> refreshHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _history = await _repository.getHistory();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _startProcessPolling() {
    _processPollTimer?.cancel();
    _processPollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await refreshProcessStatus();
      if (processState == 'done' || processState == 'error') {
        _processPollTimer?.cancel();
        await refreshHistory();
      }
    });
  }

  // ─── Process Status ───
  Future<void> refreshProcessStatus() async {
    final data = await _repository.getProcessStatus();
    if (data.isNotEmpty) {
      final newState = data['state'] ?? 'idle';
      final newStep = data['step'] ?? '';
      final newProgress = (data['progress'] as num?)?.toDouble() ?? 0.0;
      if (newState != processState || newStep != processStep || newProgress != processProgress) {
        processState = newState;
        processFilename = data['filename'] ?? '';
        processStep = newStep;
        processProgress = newProgress;
        notifyListeners();
      }
    }
  }

  // ─── Settings ───
  Future<void> refreshSettings() async {
    final data = await _repository.getSettings();
    if (data.isNotEmpty) {
      settingsEmail = data['email'] ?? '';
      settingsModel = data['model'] ?? 'medium';
      settingsLanguage = data['language'] ?? 'auto';
      notifyListeners();
    }
  }

  Future<void> updateSettings({String? email, String? model, String? language}) async {
    final body = <String, dynamic>{};
    if (email != null) { settingsEmail = email; body['email'] = email; }
    if (model != null) { settingsModel = model; body['model'] = model; }
    if (language != null) { settingsLanguage = language; body['language'] = language; }
    notifyListeners();
    await _repository.saveSettings(body);
  }

  // ─── Recording Controls ───
  Future<void> startRecording() async {
    final filename = await _repository.startRecording();
    if (filename != null) {
      _stopwatch = Stopwatch()..start();
      _recordingTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) {
          _recordingDuration = _stopwatch!.elapsed;
          notifyListeners();
        },
      );
      await refreshStatus();
    }
  }

  Future<void> stopRecording({String? customName}) async {
    _recordingTimer?.cancel();
    _stopwatch?.stop();
    _recordingDuration = Duration.zero;

    final success = await _repository.stopRecording(customName: customName);
    if (success) {
      await refreshStatus();
      _startProcessPolling();
    }
  }

  Future<void> toggleRecording({String? customName}) async {
    if (isRecording) {
      await stopRecording(customName: customName);
    } else {
      await startRecording();
    }
  }

  Future<void> rebootPi() async {
    await _repository.rebootPi();
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel();
    _processPollTimer?.cancel();
    _systemInfoPollTimer?.cancel();
    _recordingTimer?.cancel();
    _stopwatch?.stop();
    _repository.dispose();
    super.dispose();
  }
}
