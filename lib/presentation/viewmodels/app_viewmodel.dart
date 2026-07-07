import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/system_status.dart';
import '../../data/models/analysis_result.dart';
import '../../data/models/system_info.dart';
import '../../data/repositories/pi_repository.dart';
import '../../data/services/phone_recorder_service.dart';

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
  List<String> settingsEmails = [];
  String settingsModel = 'medium';
  String settingsLanguage = 'auto';
  String selectedMicrophone = 'phone';
  List<Map<String, String>> availableMicrophones = [];
  int settingsMaxRecordings = 20;
  int settingsMaxRecordingDays = 14;

  // ─── Phone Recorder ───
  final PhoneRecorderService _phoneRecorder = PhoneRecorderService();
  bool _isPhoneRecording = false;
  String? _phoneRecordError;
  String? get phoneRecordError => _phoneRecordError;

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
  String getAudioUrl(String filename) => _repository.getAudioUrl(filename);
  SystemStatus get status => _status;
  List<AnalysisResult> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isRecording => _isPhoneRecording || _status.isRecording;
  bool get isOnline => _status.online;
  Duration get recordingDuration => _recordingDuration;
  SystemInfo get systemInfo => _systemInfo;

  // ─── Initialization ───
  Future<void> _init() async {
    await Future.wait([refreshStatus(), refreshHistory(), refreshSystemInfo(), refreshSettings(), refreshMicrophones()]);
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

  // ─── Reconnect (adres değişince yeniden bağlan) ───
  Future<void> reconnect() async {
    await Future.wait([refreshStatus(), refreshHistory(), refreshSystemInfo(), refreshSettings(), refreshMicrophones()]);
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
      final rawEmails = data['emails'];
      if (rawEmails is List && rawEmails.isNotEmpty) {
        settingsEmails = rawEmails.cast<String>();
      } else if (data['email'] != null && (data['email'] as String).isNotEmpty) {
        settingsEmails = [data['email'] as String];
      } else {
        settingsEmails = [];
      }
      settingsEmail = settingsEmails.isNotEmpty ? settingsEmails.first : '';
      settingsModel = data['model'] ?? 'medium';
      settingsLanguage = data['language'] ?? 'auto';
      selectedMicrophone = data['microphone'] ?? 'phone';
      settingsMaxRecordings = (data['maxRecordings'] as num?)?.toInt() ?? 20;
      settingsMaxRecordingDays = (data['maxRecordingDays'] as num?)?.toInt() ?? 14;
      notifyListeners();
    }
  }

  Future<void> refreshMicrophones() async {
    final piList = await _repository.getMicrophones();
    availableMicrophones = [
      {'id': 'phone', 'name': 'Telefon Mikrofonu'},
      ...piList,
    ];
    // Seçili mikrofon listede yoksa telefona dön
    if (!availableMicrophones.any((m) => m['id'] == selectedMicrophone)) {
      selectedMicrophone = 'phone';
    }
    notifyListeners();
  }

  Future<void> updateSettings({List<String>? emails, String? model, String? language, String? microphone, int? maxRecordings, int? maxRecordingDays}) async {
    final body = <String, dynamic>{};
    if (emails != null) {
      settingsEmails = emails;
      settingsEmail = emails.isNotEmpty ? emails.first : '';
      body['emails'] = emails;
    }
    if (model != null) { settingsModel = model; body['model'] = model; }
    if (language != null) { settingsLanguage = language; body['language'] = language; }
    if (microphone != null) { selectedMicrophone = microphone; body['microphone'] = microphone; }
    if (maxRecordings != null) { settingsMaxRecordings = maxRecordings; body['maxRecordings'] = maxRecordings; }
    if (maxRecordingDays != null) { settingsMaxRecordingDays = maxRecordingDays; body['maxRecordingDays'] = maxRecordingDays; }
    notifyListeners();
    await _repository.saveSettings(body);
  }

  void addEmail(String email) {
    final trimmed = email.trim();
    if (!settingsEmails.contains(trimmed)) {
      updateSettings(emails: [...settingsEmails, trimmed]);
    }
  }

  void removeEmail(String email) {
    updateSettings(emails: settingsEmails.where((e) => e != email).toList());
  }

  // ─── Recording Controls ───
  Future<bool> startRecording() async {
    if (selectedMicrophone == 'phone') {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _phoneRecordError = 'permission_denied';
        notifyListeners();
        return false;
      }
      _phoneRecordError = null;
      final ok = await _phoneRecorder.startRecording();
      if (ok) {
        _isPhoneRecording = true;
        _stopwatch = Stopwatch()..start();
        _recordingTimer = Timer.periodic(
          const Duration(milliseconds: 100),
          (_) {
            _recordingDuration = _stopwatch!.elapsed;
            notifyListeners();
          },
        );
        _status = SystemStatus(online: _status.online, isRecording: true, timestamp: DateTime.now());
        notifyListeners();
      }
      return ok;
    } else {
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
        return true;
      }
      return false;
    }
  }

  Future<void> stopRecording({String? customName}) async {
    _recordingTimer?.cancel();
    _stopwatch?.stop();
    _recordingDuration = Duration.zero;

    if (_isPhoneRecording) {
      _isPhoneRecording = false;
      final file = await _phoneRecorder.stopRecording();
      _status = SystemStatus(online: _status.online, isRecording: false, timestamp: DateTime.now());
      notifyListeners();
      if (file != null) {
        processState = 'processing';
        processStep = 'upload';
        processProgress = 0;
        notifyListeners();
        final uploaded = await _phoneRecorder.uploadRecording(file, customName: customName);
        if (uploaded) {
          _startProcessPolling();
        } else {
          processState = 'error';
          processStep = 'upload_failed';
          notifyListeners();
        }
      }
    } else {
      final success = await _repository.stopRecording(customName: customName);
      if (success) {
        await refreshStatus();
        _startProcessPolling();
      }
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
    _phoneRecorder.dispose();
    _repository.dispose();
    super.dispose();
  }
}
