# Cerebrum

> OpenWolf's learning memory. Updated automatically as the AI learns from interactions.
> Do not edit manually unless correcting an error.
> Last updated: 2026-07-19

## User Preferences

- Kullanıcı Türkçe konuşuyor, kısa ve net cevap istiyor
- Dört dörtlük, "ideal" dosya yapısı ve konvansiyon isteniyor — MVVM + DDD, feature-first

## Key Learnings

- **Project:** mobile_flutter — Pi backend'e bağlanan ses kayıt/analiz Flutter uygulaması (bkz. kök `.wolf/cerebrum.md` proje geneli için)
- **[2026-07-19] Mimari:** Riverpod 2.x (manuel provider, codegen/build_runner/freezed YOK) + feature-first MVVM/DDD. Eski Provider+ChangeNotifier ve layer-first `lib/data/`+`lib/presentation/` tamamen kaldırıldı.
- **Dizin yapısı:**
  - `lib/core/` — theme, constants, l10n, utils, `errors/failures.dart` (ApiException), `network/api_client.dart` (paylaşılan HTTP client), `widgets/` (glass_panel, status_indicator — gerçekten paylaşılan olanlar), `providers/locale_provider.dart` (isTurkish toggle + l10n)
  - `lib/app/app_shell.dart` — bottom-nav + shared app bar (ConsumerWidget'a çevrildi)
  - `lib/features/<feature>/{domain,data,presentation}` — auth, admin, recording, dashboard, history, analysis, settings
  - Her feature: `domain/entities` (saf model), `domain/repositories` (abstract interface, varsa), `data/*_repository_impl.dart` (ApiClient kullanır), `presentation/{screens,providers,widgets}`
- **Provider isimlendirme:** `xxxProvider` (örn. `authNotifierProvider`, `adminUsersProvider`, `dashboardStatusProvider`) — `AsyncNotifier`/`Notifier` alt sınıfları `XxxNotifier`, `.notifier` üzerinden `ref.read(xxxProvider.notifier)` ile metodlara erişilir.
- **go_router pubspec'te var ama KULLANILMIYOR** — navigasyon hâlâ `app_shell.dart`'ta `Scaffold`+`IndexedStack` ile yapılıyor. Bilerek dokunulmadı (plan kapsamı dışı), ileride go_router'a geçiş ayrı bir karar.
- **AnalysisDetailScreen** kasıtlı olarak Riverpod'a taşınmadı — kendi lokal `State` + kendi `AudioPlayerService()` instance'ını kullanıyor (pragmatik seçim, her şeyi provider yapmaya gerek yok).
- Backend API endpoint'leri ve davranışı değişmedi (bkz. kök `.wolf/cerebrum.md`) — sadece mobile tarafı state management ve dosya yapısı değişti.

## Do-Not-Repeat

- [2026-07-19] `auth_repository_impl.dart` gibi dosyalarda map literal içindeki `if (x != null) 'key': x` satırları `use_null_aware_elements` lint'i tetikler ama `?` null-aware marker map entry'lerde kullanılamaz — bu lint'i görmezden gel, zararsız info-level uyarı.

## Decision Log

- [2026-07-19] Provider → Riverpod 2.x (manuel, codegen yok): Proje küçük (~35 dosya), build_runner ek build adımı ve `*.g.dart` yönetim maliyetine değmiyor. İleride büyürse codegen'e geçiş kolay.
- [2026-07-19] Layer-first (`core/data/domain/presentation`) → feature-first (`features/<feature>/{domain,data,presentation}`): Kök `.wolf/cerebrum.md`'deki Tropiq mimarisiyle tutarlılık ve her feature'ın kendi içinde bağımsız okunabilir/taşınabilir olması için.
- [2026-07-19] `AppViewModel` (tek god-ViewModel) dashboard/recording/history/settings/process-status provider'larına bölündü — her biri kendi polling döngüsünü ve state'ini yönetiyor, tek bir dosyada her şeyin karışması önlendi.
