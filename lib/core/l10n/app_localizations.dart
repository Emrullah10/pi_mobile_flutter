class AppLocalizations {
  final bool isTurkish;
  const AppLocalizations({required this.isTurkish});

  // ─── App Shell ───
  String get navHistory => isTurkish ? 'GEÇMİŞ' : 'HISTORY';
  String get navRecord => isTurkish ? 'KAYIT' : 'RECORD';
  String get navSystem => isTurkish ? 'SİSTEM' : 'SYSTEM';
  String get titleHistory => isTurkish ? 'GEÇMİŞ' : 'HISTORY';
  String get titleDashboard => 'VOX_OS_INTELLIGENCE';
  String get titleSettings => isTurkish ? 'SİSTEM_ÇEKİRDEK' : 'NEURAL_CORE';

  // ─── Dashboard ───
  String get recordingName => isTurkish ? 'Kayıt Adı' : 'Recording Name';
  String get recordingNameHint => isTurkish ? 'Opsiyonel — boş bırakılabilir' : 'Optional — can be left blank';
  String get skip => isTurkish ? 'ATLA' : 'SKIP';
  String get stop => isTurkish ? 'DURDUR' : 'STOP';
  String get lastSession => isTurkish ? 'SON OTURUM ÖZETİ' : 'LAST SESSION SUMMARY';
  String get processing => isTurkish ? 'İşleniyor...' : 'Processing...';
  String get analysisComplete => isTurkish ? 'Analiz tamamlandı!' : 'Analysis complete!';
  String get errorOccurred => isTurkish ? 'Hata oluştu' : 'Error occurred';
  String get stepTranscript => isTurkish ? 'Ses → Metin' : 'Audio → Text';
  String get stepAnalysis => isTurkish ? 'AI Analiz' : 'AI Analysis';
  String get stepEmail => isTurkish ? 'E-posta' : 'Email';
  String get stepDone => isTurkish ? 'Tamamlandı' : 'Done';
  String get noRecordingsYet => isTurkish ? 'Henüz kayıt yok.\nİlk kaydını başlat!' : 'No recordings yet.\nStart your first capture!';

  // ─── History ───
  String get recentScans => isTurkish ? 'Son Kayıtlar' : 'Recent Scans';
  String get items => isTurkish ? 'Kayıt' : 'Items';
  String get searchHint => isTurkish ? 'Başlık veya etiket ara...' : 'Search transcripts or tags...';
  String get noResults => isTurkish ? 'Sonuç bulunamadı.' : 'No results found.';
  String get categoryFilter => isTurkish ? 'KATEGORİ FİLTRESİ' : 'CATEGORY FILTER';
  String get clear => isTurkish ? 'TEMİZLE' : 'CLEAR';
  String get catMeeting => isTurkish ? 'Toplantı' : 'Meeting';
  String get catLesson => isTurkish ? 'Ders' : 'Lesson';
  String get catProject => isTurkish ? 'Proje' : 'Project';
  String get catGeneral => isTurkish ? 'Genel' : 'General';

  // ─── Settings ───
  String get systemConfig => isTurkish ? 'SİSTEM YAPILANDIRMASI' : 'SYSTEM CONFIGURATION';
  String get systemConfigSub => isTurkish ? 'Çekirdek işlem birimlerini ve telemetriyi yönetin.' : 'Manage core processing units and telemetry routing.';
  String get hardwareTelemetry => isTurkish ? 'DONANIM TELEMETRİSİ' : 'HARDWARE TELEMETRY';
  String get coreTemp => isTurkish ? 'Çekirdek Sıcaklığı' : 'Core Temperature';
  String get volumeUsage => isTurkish ? 'Disk Kullanımı' : 'Volume Usage';
  String get uplinkStatus => isTurkish ? 'Bağlantı Durumu' : 'Uplink Status';
  String get connected => isTurkish ? 'BAĞLI' : 'CONNECTED';
  String get offline => isTurkish ? 'ÇEVRİMDIŞI' : 'OFFLINE';
  String get neuralProcessing => isTurkish ? 'YAPAY ZEKA İŞLEME (WHISPER)' : 'NEURAL PROCESSING (WHISPER)';
  String get acousticModel => isTurkish ? 'Akustik Model Ağırlığı' : 'Acoustic Model Weight';
  String get inputLexicon => isTurkish ? 'Giriş Dili' : 'Input Lexicon';
  String get transcriptRouting => isTurkish ? 'TRANSKRİPT YÖNLENDİRME' : 'TRANSCRIPT ROUTING';
  String get emailTarget => isTurkish ? 'Alıcı E-posta Adresleri' : 'Recipient Email Addresses';
  String get emailHint => isTurkish ? 'Adres ekle ve ✓ bas...' : 'Add address and press ✓...';
  String get emailInvalid => isTurkish ? 'Geçersiz e-posta adresi' : 'Invalid email address';
  String get emailDuplicate => isTurkish ? 'Bu adres zaten ekli' : 'Address already added';
  String get microphoneSource => isTurkish ? 'KAYIT KAYNAĞI' : 'RECORDING SOURCE';
  String get phoneMic => isTurkish ? 'Telefon Mikrofonu' : 'Phone Microphone';
  String get piMics => isTurkish ? 'Pi USB Mikrofonları' : 'Pi USB Microphones';
  String get micRefresh => isTurkish ? 'Yenile' : 'Refresh';
  String get micPermissionDenied => isTurkish ? 'Mikrofon izni gerekli' : 'Microphone permission required';
  String get micUploading => isTurkish ? 'Pi\'ye yükleniyor...' : 'Uploading to Pi...';
  String get storageTitle => isTurkish ? 'DEPOLAMA YÖNETİMİ' : 'STORAGE MANAGEMENT';
  String get maxRecordings => isTurkish ? 'Maksimum Kayıt Sayısı' : 'Max Recordings';
  String get maxRecordingDays => isTurkish ? 'Maksimum Saklama (gün)' : 'Max Retention (days)';
  String get playRecording => isTurkish ? 'OYNAT' : 'PLAY';
  String get audioNotFound => isTurkish ? 'Ses dosyası bulunamadı' : 'Audio file not found';
  String get storageHint => isTurkish ? 'Bu sınırları aşan eski ses kayıtları otomatik silinir. Analiz metinleri korunur.' : 'Old recordings exceeding these limits are auto-deleted. Analysis texts are kept.';
  String get systemInstance => isTurkish ? 'SİSTEM ÖRNEĞİ' : 'SYSTEM INSTANCE';
  String get uptime => isTurkish ? 'Çalışma Süresi' : 'Uptime';
  String get reboot => isTurkish ? 'YENİDEN BAŞLAT' : 'INITIATE REBOOT CYCLE';
  String get modelInfo => isTurkish ? 'Model Seçimi' : 'Model Selection';
  String get ok => isTurkish ? 'TAMAM' : 'OK';

  String get langAutoDetect => isTurkish ? 'Otomatik Algıla' : 'Auto-Detect Stream';
  String get langEnglish => isTurkish ? 'İngilizce (US)' : 'English (US)';
  String get langTurkish => isTurkish ? 'Türkçe (TR)' : 'Turkish (TR)';
  String get langSpanish => isTurkish ? 'İspanyolca (ES)' : 'Spanish (ES)';

  List<String> get langLabels => [langAutoDetect, langEnglish, langTurkish, langSpanish];

  String get modelBaseDesc => isTurkish
      ? 'En hızlı model. Kısa ve net konuşmalar için idealdir. Doğruluğu düşük olabilir.'
      : 'Fastest model. Ideal for short, clear speech. Accuracy may be lower.';
  String get modelSmallDesc => isTurkish
      ? 'Hız ve doğruluk dengesi. Çoğu kullanım için yeterlidir.'
      : 'Balance of speed and accuracy. Sufficient for most use cases.';
  String get modelMediumDesc => isTurkish
      ? 'En doğru model. Uzun toplantılar için önerilir. Pi\'yi ısıtır.'
      : 'Most accurate model. Recommended for long meetings. Heats the Pi.';

  // ─── Server Config ───
  String get serverConfig => isTurkish ? 'SUNUCU ADRESİ' : 'SERVER ADDRESS';
  String get serverAddressHint => '192.168.1.39:3000';
  String get serverSaved => isTurkish ? 'Adres kaydedildi. Yeniden bağlanılıyor...' : 'Address saved. Reconnecting...';
  String get autoDiscover => isTurkish ? 'OTOMATİK BUL' : 'AUTO DISCOVER';
  String get discoverFailed => isTurkish ? 'Pi ağda bulunamadı (whisperpi.local)' : 'Pi not found on network (whisperpi.local)';
  String get discoverSuccess => isTurkish ? 'Pi bulundu: ' : 'Pi found: ';

  // ─── Analysis Detail ───
  String get transcription => isTurkish ? 'Transkripsiyon' : 'Transcription';
  String get autoGenerated => 'AUTO-GENERATED';
  String get transcriptPending => isTurkish ? 'İşlemden sonra görünecek.' : 'Transcript will appear after processing.';
  String get aiSummary => isTurkish ? 'AI Özeti' : 'AI Summary';
  String get noSummary => isTurkish ? 'Özet oluşturulmadı.' : 'No summary generated.';
  String get actionItems => isTurkish ? 'Aksiyon Maddeleri' : 'Action Items';
  String get deliveryStatus => isTurkish ? 'TESLİM DURUMU' : 'DELIVERY STATUS';
  String get participants => isTurkish ? 'Katılımcı' : 'Participants';
}
