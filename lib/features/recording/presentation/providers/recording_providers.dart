import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/phone_recorder_service.dart';

class RecordingUiState {
  final bool isPhoneRecording;
  final String? phoneRecordError;
  final Duration duration;

  const RecordingUiState({
    this.isPhoneRecording = false,
    this.phoneRecordError,
    this.duration = Duration.zero,
  });

  RecordingUiState copyWith({
    bool? isPhoneRecording,
    String? phoneRecordError,
    bool clearError = false,
    Duration? duration,
  }) {
    return RecordingUiState(
      isPhoneRecording: isPhoneRecording ?? this.isPhoneRecording,
      phoneRecordError: clearError ? null : (phoneRecordError ?? this.phoneRecordError),
      duration: duration ?? this.duration,
    );
  }
}

/// Owns the phone-mic recorder, the recording stopwatch, and orchestrates
/// starting/stopping recordings on either the phone mic or the Pi mic.
class RecordingNotifier extends Notifier<RecordingUiState> {
  final PhoneRecorderService _phoneRecorder = PhoneRecorderService();
  Timer? _recordingTimer;
  Stopwatch? _stopwatch;

  @override
  RecordingUiState build() {
    ref.onDispose(() {
      _recordingTimer?.cancel();
      _stopwatch?.stop();
      _phoneRecorder.dispose();
    });
    return const RecordingUiState();
  }

  bool get isRecording => state.isPhoneRecording || ref.read(systemStatusProvider).isRecording;

  void _startTimer() {
    _stopwatch = Stopwatch()..start();
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      state = state.copyWith(duration: _stopwatch!.elapsed);
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _stopwatch?.stop();
    state = state.copyWith(duration: Duration.zero);
  }

  Future<bool> startRecording() async {
    final selectedMic = ref.read(selectedMicrophoneProvider);
    if (selectedMic == 'phone') {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        state = state.copyWith(phoneRecordError: 'permission_denied');
        return false;
      }
      state = state.copyWith(clearError: true);
      final ok = await _phoneRecorder.startRecording();
      if (ok) {
        state = state.copyWith(isPhoneRecording: true);
        _startTimer();
        ref.read(systemStatusProvider.notifier).setRecording(true);
      }
      return ok;
    } else {
      final filename = await _startPiRecording();
      if (filename != null) {
        _startTimer();
        await ref.read(systemStatusProvider.notifier).refreshStatus();
        return true;
      }
      return false;
    }
  }

  Future<String?> _startPiRecording() async {
    final apiClient = ApiClient();
    try {
      final json = await apiClient.post(ApiConstants.recordStart);
      return json['file'] as String?;
    } catch (_) {
      return null;
    } finally {
      apiClient.dispose();
    }
  }

  Future<bool> _stopPiRecording({String? customName}) async {
    final apiClient = ApiClient();
    try {
      await apiClient.post(
        ApiConstants.recordStop,
        body: customName != null ? {'customName': customName} : null,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      apiClient.dispose();
    }
  }

  Future<void> stopRecording({String? customName}) async {
    _stopTimer();

    if (state.isPhoneRecording) {
      state = state.copyWith(isPhoneRecording: false);
      final file = await _phoneRecorder.stopRecording();
      ref.read(systemStatusProvider.notifier).setRecording(false);
      if (file != null) {
        final processNotifier = ref.read(processStatusProvider.notifier);
        processNotifier.setUploading();
        final uploaded = await _phoneRecorder.uploadRecording(file, customName: customName);
        if (uploaded) {
          processNotifier.startPolling();
        } else {
          processNotifier.setUploadFailed();
        }
      }
    } else {
      final success = await _stopPiRecording(customName: customName);
      if (success) {
        await ref.read(systemStatusProvider.notifier).refreshStatus();
        ref.read(processStatusProvider.notifier).startPolling();
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
}

final recordingProvider = NotifierProvider<RecordingNotifier, RecordingUiState>(RecordingNotifier.new);

/// True if either the phone mic or the Pi is actively recording.
final isRecordingProvider = Provider<bool>((ref) {
  final phoneRecording = ref.watch(recordingProvider).isPhoneRecording;
  final piRecording = ref.watch(systemStatusProvider).isRecording;
  return phoneRecording || piRecording;
});
