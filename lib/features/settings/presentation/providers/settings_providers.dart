import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

/// Plain URL builder for a recording's audio file.
String getAudioUrl(String filename) =>
    '${ApiConstants.baseUrl}${ApiConstants.audioFile(filename)}';

class SettingsState {
  final String email;
  final List<String> emails;
  final String model;
  final String language;
  final int maxRecordings;
  final int maxRecordingDays;

  const SettingsState({
    this.email = '',
    this.emails = const [],
    this.model = 'medium',
    this.language = 'auto',
    this.maxRecordings = 20,
    this.maxRecordingDays = 14,
  });

  SettingsState copyWith({
    String? email,
    List<String>? emails,
    String? model,
    String? language,
    int? maxRecordings,
    int? maxRecordingDays,
  }) {
    return SettingsState(
      email: email ?? this.email,
      emails: emails ?? this.emails,
      model: model ?? this.model,
      language: language ?? this.language,
      maxRecordings: maxRecordings ?? this.maxRecordings,
      maxRecordingDays: maxRecordingDays ?? this.maxRecordingDays,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  Future<SettingsState> build() async {
    return _fetch();
  }

  Future<SettingsState> _fetch() async {
    final data = await _repo.getSettings();
    if (data.isEmpty) return const SettingsState();

    List<String> emails;
    final rawEmails = data['emails'];
    if (rawEmails is List && rawEmails.isNotEmpty) {
      emails = rawEmails.cast<String>();
    } else if (data['email'] != null && (data['email'] as String).isNotEmpty) {
      emails = [data['email'] as String];
    } else {
      emails = [];
    }

    return SettingsState(
      email: emails.isNotEmpty ? emails.first : '',
      emails: emails,
      model: data['model'] ?? 'medium',
      language: data['language'] ?? 'auto',
      maxRecordings: (data['maxRecordings'] as num?)?.toInt() ?? 20,
      maxRecordingDays: (data['maxRecordingDays'] as num?)?.toInt() ?? 14,
    );
  }

  Future<void> refreshSettings() async {
    state = AsyncData(await _fetch());
  }

  Future<void> updateSettings({
    List<String>? emails,
    String? model,
    String? language,
    int? maxRecordings,
    int? maxRecordingDays,
  }) async {
    final current = state.valueOrNull ?? const SettingsState();
    final body = <String, dynamic>{};
    var next = current;

    if (emails != null) {
      next = next.copyWith(emails: emails, email: emails.isNotEmpty ? emails.first : '');
      body['emails'] = emails;
    }
    if (model != null) {
      next = next.copyWith(model: model);
      body['model'] = model;
    }
    if (language != null) {
      next = next.copyWith(language: language);
      body['language'] = language;
    }
    if (maxRecordings != null) {
      next = next.copyWith(maxRecordings: maxRecordings);
      body['maxRecordings'] = maxRecordings;
    }
    if (maxRecordingDays != null) {
      next = next.copyWith(maxRecordingDays: maxRecordingDays);
      body['maxRecordingDays'] = maxRecordingDays;
    }

    state = AsyncData(next);
    await _repo.saveSettings(body);
  }

  void addEmail(String email) {
    final trimmed = email.trim();
    final current = state.valueOrNull ?? const SettingsState();
    if (!current.emails.contains(trimmed)) {
      updateSettings(emails: [...current.emails, trimmed]);
    }
  }

  void removeEmail(String email) {
    final current = state.valueOrNull ?? const SettingsState();
    updateSettings(emails: current.emails.where((e) => e != email).toList());
  }

  Future<void> rebootPi() async {
    await _repo.rebootPi();
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

/// Currently selected microphone id — 'phone' or a Pi mic id.
class SelectedMicrophoneNotifier extends Notifier<String> {
  @override
  String build() => 'phone';

  void select(String id) => state = id;
}

final selectedMicrophoneProvider = NotifierProvider<SelectedMicrophoneNotifier, String>(SelectedMicrophoneNotifier.new);

/// List of available microphones — phone mic prepended to whatever the Pi reports.
class MicrophoneListNotifier extends AsyncNotifier<List<Map<String, String>>> {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  Future<List<Map<String, String>>> build() async {
    return _fetch();
  }

  Future<List<Map<String, String>>> _fetch() async {
    final piList = await _repo.getMicrophones();
    final list = [
      {'id': 'phone', 'name': 'Telefon Mikrofonu'},
      ...piList,
    ];
    final selectedNotifier = ref.read(selectedMicrophoneProvider.notifier);
    if (!list.any((m) => m['id'] == ref.read(selectedMicrophoneProvider))) {
      selectedNotifier.select('phone');
    }
    return list;
  }

  Future<void> refreshMicrophones() async {
    state = AsyncData(await _fetch());
  }
}

final microphoneListProvider = AsyncNotifierProvider<MicrophoneListNotifier, List<Map<String, String>>>(MicrophoneListNotifier.new);
