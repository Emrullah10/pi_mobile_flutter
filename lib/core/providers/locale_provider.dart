import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';

/// Tracks whether the UI language is Turkish (default) or English.
class LocaleNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

final localeProvider = NotifierProvider<LocaleNotifier, bool>(LocaleNotifier.new);

final l10nProvider = Provider<AppLocalizations>((ref) {
  final isTurkish = ref.watch(localeProvider);
  return AppLocalizations(isTurkish: isTurkish);
});
