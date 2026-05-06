import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/system_info.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../../widgets/glass_panel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
      builder: (context, vm, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(vm.l10n.systemConfig, style: AppTypography.h2.copyWith(color: AppColors.onBackground)),
            const SizedBox(height: 4),
            Text(vm.l10n.systemConfigSub, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 32),
            _HardwareCard(info: vm.systemInfo, isOnline: vm.isOnline, vm: vm),
            const SizedBox(height: 24),
            _WhisperCard(vm: vm),
            const SizedBox(height: 24),
            _RoutingCard(vm: vm),
            const SizedBox(height: 24),
            _SystemCard(info: vm.systemInfo, isOnline: vm.isOnline, vm: vm),
          ]),
        );
      },
    );
  }
}

class _HardwareCard extends StatelessWidget {
  final SystemInfo info;
  final bool isOnline;
  final AppViewModel vm;

  const _HardwareCard({required this.info, required this.isOnline, required this.vm});

  @override
  Widget build(BuildContext context) {
    final diskPercent = info.diskTotalGb > 0 ? info.diskUsedGb / info.diskTotalGb : 0.0;
    final tempColor = info.cpuTemp > 70
        ? AppColors.error
        : info.cpuTemp > 55
            ? AppColors.tertiaryFixedDim
            : AppColors.primaryContainer;

    return GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.developer_board, vm.l10n.hardwareTelemetry),
      const SizedBox(height: 16),
      _settingRow(
        icon: Icons.thermostat,
        label: vm.l10n.coreTemp,
        trailing: Text(
          isOnline ? '${info.cpuTemp}°C' : '--',
          style: AppTypography.h3.copyWith(color: tempColor),
        ),
      ),
      const SizedBox(height: 12),
      _storageRow(info, diskPercent),
      const SizedBox(height: 12),
      _connectionRow(isOnline),
    ]));
  }

  Widget _storageRow(SystemInfo info, double diskPercent) {
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
            Text(vm.l10n.volumeUsage, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface)),
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

  Widget _connectionRow(bool isOnline) {
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
          Text(vm.l10n.uplinkStatus, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface)),
        ]),
        Row(children: [
          if (isOnline) _PingDot(),
          if (!isOnline) Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.outline)),
          const SizedBox(width: 8),
          Text(
            isOnline ? vm.l10n.connected : vm.l10n.offline,
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

class _WhisperCard extends StatefulWidget {
  final AppViewModel vm;
  const _WhisperCard({required this.vm});
  @override State<_WhisperCard> createState() => _WhisperCardState();
}

class _WhisperCardState extends State<_WhisperCard> {
  static const _modelKeys = ['base', 'small', 'medium'];
  static const _langKeys = ['auto', 'en', 'tr', 'es'];
  int get _selectedModel => _modelKeys.indexOf(widget.vm.settingsModel).clamp(0, 2);
  String get _selectedLang => widget.vm.l10n.langLabels[_langKeys.indexOf(widget.vm.settingsLanguage).clamp(0, 3)];

  void _showAllModelsInfo(BuildContext context) {
    final l = widget.vm.l10n;
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
    final l = widget.vm.l10n;
    return GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.graphic_eq, l.neuralProcessing),
      const SizedBox(height: 16),
      Row(children: [
        Text(l.acousticModel, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => _showAllModelsInfo(context),
          child: const Icon(Icons.info_outline, size: 14, color: AppColors.outline),
        ),
      ]),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
        child: Row(children: List.generate(3, (i) {
          final labels = ['BASE', 'SMALL', 'MEDIUM'];
          final isActive = i == _selectedModel;
          return Expanded(child: GestureDetector(
            onTap: () => widget.vm.updateSettings(model: _modelKeys[i]),
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
          value: _selectedLang,
          isExpanded: true,
          dropdownColor: AppColors.surfaceContainer,
          icon: const Icon(Icons.expand_more, color: AppColors.outline),
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          items: l.langLabels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => widget.vm.updateSettings(language: _langKeys[l.langLabels.indexOf(v!)]),
        )),
      ),
    ]));
  }
}

class _RoutingCard extends StatefulWidget {
  final AppViewModel vm;
  const _RoutingCard({required this.vm});
  @override
  State<_RoutingCard> createState() => _RoutingCardState();
}

class _RoutingCardState extends State<_RoutingCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.vm.settingsEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.mark_email_read, widget.vm.l10n.transcriptRouting),
      const SizedBox(height: 16),
      Text(widget.vm.l10n.emailTarget, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.outlineVariant)),
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.emailAddress,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.alternate_email, color: AppColors.outline),
            hintText: widget.vm.l10n.emailHint,
            border: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            suffixIcon: IconButton(
              icon: const Icon(Icons.check, color: AppColors.primary),
              onPressed: () {
                widget.vm.updateSettings(email: _controller.text.trim());
                FocusScope.of(context).unfocus();
              },
            ),
          ),
        ),
      ),
    ]));
  }
}

class _SystemCard extends StatelessWidget {
  final SystemInfo info;
  final bool isOnline;
  final AppViewModel vm;

  const _SystemCard({required this.info, required this.isOnline, required this.vm});

  @override
  Widget build(BuildContext context) {
    final uptimeStr = isOnline ? '${info.uptimeHours}h ${info.uptimeMinutes}m ago' : '--';

    return GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader(Icons.terminal, vm.l10n.systemInstance),
      const SizedBox(height: 16),
      _infoRow(vm.l10n.uptime, uptimeStr),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(
        onPressed: isOnline ? () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppColors.zinc950,
              title: Text(vm.l10n.reboot, style: AppTypography.labelCaps.copyWith(color: AppColors.error)),
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
          if (confirm == true) await vm.rebootPi();
        } : null,
        icon: const Icon(Icons.power_settings_new, size: 18),
        label: Text(vm.l10n.reboot, style: AppTypography.labelCaps),
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
