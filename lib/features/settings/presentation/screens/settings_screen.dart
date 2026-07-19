import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/server_config.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/discovery_service.dart';
import '../../domain/entities/system_info.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final systemInfo = ref.watch(systemInfoProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.systemConfig, style: AppTypography.h2.copyWith(color: AppColors.onBackground)),
        const SizedBox(height: 4),
        Text(l10n.systemConfigSub, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 32),
        _HardwareCard(info: systemInfo, isOnline: isOnline),
        const SizedBox(height: 24),
        const _ServerConfigCard(),
        const SizedBox(height: 24),
        const _WhisperCard(),
        const SizedBox(height: 24),
        const _MicrophoneCard(),
        const SizedBox(height: 24),
        const _StorageCard(),
        const SizedBox(height: 24),
        const _RoutingCard(),
        const SizedBox(height: 24),
        _SystemCard(info: systemInfo, isOnline: isOnline),
      ]),
    );
  }
}

class _ServerConfigCard extends ConsumerStatefulWidget {
  const _ServerConfigCard();
  @override
  ConsumerState<_ServerConfigCard> createState() => _ServerConfigCardState();
}

class _ServerConfigCardState extends ConsumerState<_ServerConfigCard> {
  late final TextEditingController _controller;
  bool _discovering = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ServerConfig.baseUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = ref.read(l10nProvider);
    await ServerConfig.setBaseUrl(_controller.text.trim());
    _controller.text = ServerConfig.baseUrl;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.serverSaved, style: AppTypography.bodyMd)),
      );
    }
    await reconnectAll(ref);
  }

  Future<void> _discover() async {
    final l10n = ref.read(l10nProvider);
    setState(() => _discovering = true);
    final ip = await DiscoveryService().discoverPiIp();
    if (!mounted) return;
    setState(() => _discovering = false);
    if (ip != null) {
      final url = 'http://$ip:3000';
      _controller.text = url;
      await ServerConfig.setBaseUrl(url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.discoverSuccess}$ip', style: AppTypography.bodyMd)),
        );
      }
      await reconnectAll(ref);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.discoverFailed, style: AppTypography.bodyMd)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(l10nProvider);
    return GlassPanel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.router, l.serverConfig),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: TextField(
            controller: _controller,
            style: AppTypography.mono.copyWith(color: AppColors.onSurface),
            keyboardType: TextInputType.url,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.language, color: AppColors.outline),
              hintText: l.serverAddressHint,
              hintStyle: AppTypography.mono.copyWith(color: AppColors.outline),
              border: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check, color: AppColors.primary),
                onPressed: _save,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _discovering ? null : _discover,
            icon: _discovering
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.radar, size: 16),
            label: Text(l.autoDiscover, style: AppTypography.labelCaps.copyWith(fontSize: 11)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryFixedDim,
              side: BorderSide(color: AppColors.primaryFixedDim.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _HardwareCard extends ConsumerWidget {
  final SystemInfo info;
  final bool isOnline;

  const _HardwareCard({required this.info, required this.isOnline});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final diskPercent = info.diskTotalGb > 0 ? info.diskUsedGb / info.diskTotalGb : 0.0;
    final tempColor = info.cpuTemp > 70
        ? AppColors.error
        : info.cpuTemp > 55
            ? AppColors.tertiaryFixedDim
            : AppColors.primaryContainer;

    return GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.developer_board, l10n.hardwareTelemetry),
      const SizedBox(height: 16),
      _settingRow(
        icon: Icons.thermostat,
        label: l10n.coreTemp,
        trailing: Text(
          isOnline ? '${info.cpuTemp}°C' : '--',
          style: AppTypography.h3.copyWith(color: tempColor),
        ),
      ),
      const SizedBox(height: 12),
      _storageRow(l10n, diskPercent),
      const SizedBox(height: 12),
      _connectionRow(l10n),
    ]));
  }

  Widget _storageRow(AppLocalizations l10n, double diskPercent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(Icons.storage, color: AppColors.outline, size: 20),
            const SizedBox(width: 16),
            Text(l10n.volumeUsage, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface)),
          ]),
          Text(
            isOnline ? '${info.diskUsedGb.toStringAsFixed(1)} GB / ${info.diskTotalGb.toStringAsFixed(1)} GB' : '-- / --',
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: diskPercent.toDouble(),
            minHeight: 6,
            backgroundColor: AppColors.surfaceContainerHighest,
            color: diskPercent > 0.85 ? AppColors.error : AppColors.primary,
          ),
        ),
      ]),
    );
  }

  Widget _connectionRow(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Icon(Icons.router, color: AppColors.outline, size: 20),
          const SizedBox(width: 16),
          Text(l10n.uplinkStatus, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface)),
        ]),
        Row(children: [
          if (isOnline) _PingDot(),
          if (!isOnline) Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.outline)),
          const SizedBox(width: 8),
          Text(
            isOnline ? l10n.connected : l10n.offline,
            style: AppTypography.labelCaps.copyWith(
              color: isOnline ? AppColors.primaryContainer : AppColors.outline,
            ),
          ),
        ]),
      ]),
    );
  }
}

class _PingDot extends StatefulWidget {
  @override
  State<_PingDot> createState() => _PingDotState();
}

class _PingDotState extends State<_PingDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 12, height: 12, child: Stack(alignment: Alignment.center, children: [
      FadeTransition(
        opacity: Tween(begin: 0.7, end: 0.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut)),
        child: ScaleTransition(
          scale: Tween(begin: 1.0, end: 2.5).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut)),
          child: Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryFixed.withValues(alpha: 0.75))),
        ),
      ),
      Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryContainer, boxShadow: [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.8), blurRadius: 8)])),
    ]));
  }
}

class _WhisperCard extends ConsumerStatefulWidget {
  const _WhisperCard();
  @override ConsumerState<_WhisperCard> createState() => _WhisperCardState();
}

class _WhisperCardState extends ConsumerState<_WhisperCard> {
  static const _modelKeys = ['base', 'small', 'medium'];
  static const _langKeys = ['auto', 'en', 'tr', 'es'];

  int _selectedModel(String model) => _modelKeys.indexOf(model).clamp(0, 2);
  String _selectedLang(AppLocalizations l10n, String language) =>
      l10n.langLabels[_langKeys.indexOf(language).clamp(0, 3)];

  void _showAllModelsInfo(BuildContext context, AppLocalizations l) {
    final modelInfos = [
      ('BASE', l.modelBaseDesc),
      ('SMALL', l.modelSmallDesc),
      ('MEDIUM', l.modelMediumDesc),
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(l.modelInfo, style: AppTypography.labelCaps.copyWith(color: AppColors.primary, letterSpacing: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: modelInfos.map((info) {
            final (label, desc) = info;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(desc, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              ]),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.ok, style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(l10nProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final model = settings?.model ?? 'medium';
    final language = settings?.language ?? 'auto';
    final selectedModel = _selectedModel(model);
    final selectedLang = _selectedLang(l, language);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.graphic_eq, l.neuralProcessing),
      const SizedBox(height: 16),
      Row(children: [
        Text(l.acousticModel, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => _showAllModelsInfo(context, l),
          child: const Icon(Icons.info_outline, size: 14, color: AppColors.outline),
        ),
      ]),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
        child: Row(children: List.generate(3, (i) {
          final labels = ['BASE', 'SMALL', 'MEDIUM'];
          final isActive = i == selectedModel;
          return Expanded(child: GestureDetector(
            onTap: () => settingsNotifier.updateSettings(model: _modelKeys[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.surfaceContainerHighest : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8)] : null,
              ),
              child: Center(child: Text(labels[i], style: AppTypography.labelCaps.copyWith(color: isActive ? AppColors.primary : AppColors.onSurfaceVariant))),
            ),
          ));
        })),
      ),
      const SizedBox(height: 24),
      Text(l.inputLexicon, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.outlineVariant)),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: selectedLang,
          isExpanded: true,
          dropdownColor: AppColors.surfaceContainer,
          icon: const Icon(Icons.expand_more, color: AppColors.outline),
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          items: l.langLabels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => settingsNotifier.updateSettings(language: _langKeys[l.langLabels.indexOf(v!)]),
        )),
      ),
    ]));
  }
}

class _MicrophoneCard extends ConsumerWidget {
  const _MicrophoneCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final availableMicrophones = ref.watch(microphoneListProvider).valueOrNull ?? [];
    final selectedMicrophone = ref.watch(selectedMicrophoneProvider);

    final mics = availableMicrophones.isEmpty
        ? [{'id': 'phone', 'name': l10n.phoneMic}]
        : availableMicrophones;

    return GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _sectionHeader(Icons.mic, l10n.microphoneSource),
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.outline, size: 18),
          tooltip: l10n.micRefresh,
          onPressed: () => ref.read(microphoneListProvider.notifier).refreshMicrophones(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ]),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: mics.any((m) => m['id'] == selectedMicrophone)
                ? selectedMicrophone
                : 'phone',
            isExpanded: true,
            dropdownColor: AppColors.surfaceContainer,
            icon: const Icon(Icons.expand_more, color: AppColors.outline),
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
            items: mics.map((m) => DropdownMenuItem(
              value: m['id'],
              child: Row(children: [
                Icon(
                  m['id'] == 'phone' ? Icons.smartphone : Icons.usb,
                  size: 16,
                  color: AppColors.outline,
                ),
                const SizedBox(width: 10),
                Text(m['id'] == 'phone' ? l10n.phoneMic : m['name']!),
              ]),
            )).toList(),
            onChanged: (v) {
              if (v != null) {
                ref.read(selectedMicrophoneProvider.notifier).select(v);
              }
            },
          ),
        ),
      ),
      if (!isOnline) ...[
        const SizedBox(height: 8),
        Text(
          'Pi çevrimdışı — sadece telefon mikrofonu',
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    ]));
  }
}

class _StorageCard extends ConsumerWidget {
  const _StorageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(l10nProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final maxRecordings = settings?.maxRecordings ?? 20;
    final maxRecordingDays = settings?.maxRecordingDays ?? 14;
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.sd_storage, l.storageTitle),
      const SizedBox(height: 16),
      _stepperRow(
        label: l.maxRecordings,
        value: maxRecordings,
        suffix: '',
        min: 1,
        max: 200,
        step: 5,
        onChanged: (v) => settingsNotifier.updateSettings(maxRecordings: v),
      ),
      const SizedBox(height: 12),
      _stepperRow(
        label: l.maxRecordingDays,
        value: maxRecordingDays,
        suffix: '',
        min: 1,
        max: 365,
        step: 1,
        onChanged: (v) => settingsNotifier.updateSettings(maxRecordingDays: v),
      ),
      const SizedBox(height: 12),
      Text(l.storageHint, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
    ]));
  }

  Widget _stepperRow({
    required String label,
    required int value,
    required String suffix,
    required int min,
    required int max,
    required int step,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(label, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface))),
        Row(children: [
          _stepBtn(Icons.remove, value > min, () => onChanged((value - step).clamp(min, max))),
          Container(
            constraints: const BoxConstraints(minWidth: 44),
            alignment: Alignment.center,
            child: Text('$value$suffix', style: AppTypography.monoLg.copyWith(color: AppColors.primary)),
          ),
          _stepBtn(Icons.add, value < max, () => onChanged((value + step).clamp(min, max))),
        ]),
      ]),
    );
  }

  Widget _stepBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, size: 18, color: enabled ? AppColors.primary : AppColors.outline),
      ),
    );
  }
}

class _RoutingCard extends ConsumerStatefulWidget {
  const _RoutingCard();
  @override
  ConsumerState<_RoutingCard> createState() => _RoutingCardState();
}

class _RoutingCardState extends ConsumerState<_RoutingCard> {
  late final TextEditingController _controller;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addEmail(BuildContext context, List<String> emails) {
    final l10n = ref.read(l10nProvider);
    final val = _controller.text.trim();
    if (val.isEmpty) return;
    if (!_emailRegex.hasMatch(val)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emailInvalid), duration: const Duration(seconds: 2)),
      );
      return;
    }
    if (emails.contains(val)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emailDuplicate), duration: const Duration(seconds: 2)),
      );
      return;
    }
    ref.read(settingsProvider.notifier).addEmail(val);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final emails = ref.watch(settingsProvider).valueOrNull?.emails ?? [];
    return GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.mark_email_read, l10n.transcriptRouting),
      const SizedBox(height: 16),
      Text(l10n.emailTarget, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 8),
      if (emails.isNotEmpty) ...[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: emails.map((addr) => _EmailChip(
            address: addr,
            onRemove: () => ref.read(settingsProvider.notifier).removeEmail(addr),
          )).toList(),
        ),
        const SizedBox(height: 12),
      ],
      Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.emailAddress,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          onSubmitted: (_) => _addEmail(context, emails),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.alternate_email, color: AppColors.outline),
            hintText: l10n.emailHint,
            border: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            suffixIcon: IconButton(
              icon: const Icon(Icons.check, color: AppColors.primary),
              onPressed: () => _addEmail(context, emails),
            ),
          ),
        ),
      ),
    ]));
  }
}

class _EmailChip extends StatelessWidget {
  final String address;
  final VoidCallback onRemove;

  const _EmailChip({required this.address, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.email_outlined, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(address, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface)),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onRemove,
          child: Icon(Icons.close, size: 14, color: AppColors.onSurfaceVariant),
        ),
      ]),
    );
  }
}

class _SystemCard extends ConsumerWidget {
  final SystemInfo info;
  final bool isOnline;

  const _SystemCard({required this.info, required this.isOnline});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final uptimeStr = isOnline ? '${info.uptimeHours}h ${info.uptimeMinutes}m ago' : '--';

    return GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.terminal, l10n.systemInstance),
      const SizedBox(height: 16),
      _infoRow(l10n.uptime, uptimeStr),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(
        onPressed: isOnline ? () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppColors.zinc950,
              title: Text(l10n.reboot, style: AppTypography.labelCaps.copyWith(color: AppColors.error)),
              content: Text('Raspberry Pi yeniden başlatılacak. Devam edilsin mi?',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false),
                    child: Text('İptal', style: TextStyle(color: AppColors.onSurfaceVariant))),
                TextButton(onPressed: () => Navigator.pop(context, true),
                    child: Text('Başlat', style: TextStyle(color: AppColors.error))),
              ],
            ),
          );
          if (confirm == true) await ref.read(settingsProvider.notifier).rebootPi();
        } : null,
        icon: const Icon(Icons.power_settings_new, size: 18),
        label: Text(l10n.reboot, style: AppTypography.labelCaps),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorContainer.withValues(alpha: 0.2),
          foregroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: AppColors.error.withValues(alpha: 0.3))),
        ),
      )),
    ]));
  }

  Widget _infoRow(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
      Text(value, style: AppTypography.monoLg.copyWith(color: AppColors.onSurface)),
    ]);
  }
}

Widget _sectionHeader(IconData icon, String title) {
  return Row(children: [
    Icon(icon, color: AppColors.primary, size: 20),
    const SizedBox(width: 8),
    Text(title, style: AppTypography.labelCaps.copyWith(color: AppColors.primary, letterSpacing: 2)),
  ]);
}

Widget _settingRow({required IconData icon, required String label, required Widget trailing}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [Icon(icon, color: AppColors.outline, size: 20), const SizedBox(width: 16), Text(label, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface))]),
      trailing,
    ]),
  );
}
