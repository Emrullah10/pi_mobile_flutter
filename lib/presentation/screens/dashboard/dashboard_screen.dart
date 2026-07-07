import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/status_indicator.dart';
import '../../widgets/record_orb.dart';
import '../../widgets/tag_chip.dart';

import '../../viewmodels/auth_viewmodel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final isAdmin = authVm.isAdmin;

    return Consumer<AppViewModel>(
      builder: (context, vm, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            children: [
              GlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderRadius: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusIndicator(isOnline: vm.isOnline, isRecording: vm.isRecording),
                    Row(children: [
                      Icon(
                        vm.isOnline ? Icons.wifi : Icons.wifi_off,
                        size: 16,
                        color: vm.isOnline ? AppColors.primaryContainer : AppColors.outline,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.thermostat,
                        size: 16,
                        color: vm.isOnline
                            ? (vm.systemInfo.cpuTemp > 70
                                ? AppColors.error
                                : vm.systemInfo.cpuTemp > 55
                                    ? AppColors.tertiaryFixedDim
                                    : AppColors.primaryContainer)
                            : AppColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vm.isOnline ? '${vm.systemInfo.cpuTemp}°' : '--',
                        style: AppTypography.bodyMd.copyWith(
                          fontSize: 11,
                          color: vm.isOnline
                              ? (vm.systemInfo.cpuTemp > 70
                                  ? AppColors.error
                                  : vm.systemInfo.cpuTemp > 55
                                      ? AppColors.tertiaryFixedDim
                                      : AppColors.primaryContainer)
                              : AppColors.outline,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              if (isAdmin) ...[
                Text(
                  Formatters.formatDuration(vm.recordingDuration),
                  style: AppTypography.h1.copyWith(
                    color: AppColors.primaryContainer.withValues(alpha: 0.8),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 32),
                RecordOrb(
                  isRecording: vm.isRecording,
                  onTap: () async {
                    if (vm.isRecording) {
                      final controller = TextEditingController();
                      final name = await showDialog<String>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: AppColors.surfaceContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          title: Text(vm.l10n.recordingName, style: AppTypography.labelCaps.copyWith(color: AppColors.primary, letterSpacing: 2)),
                          content: TextField(
                            controller: controller,
                            autofocus: true,
                            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                            decoration: InputDecoration(
                              hintText: vm.l10n.recordingNameHint,
                              hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.outlineVariant)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, ''),
                              child: Text(vm.l10n.skip, style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, controller.text.trim()),
                              child: Text(vm.l10n.stop, style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
                            ),
                          ],
                        ),
                      );
                      if (name != null) {
                        await vm.toggleRecording(customName: name.isEmpty ? null : name);
                      }
                    } else {
                      await vm.toggleRecording();
                    }
                  },
                ),
              ] else ...[
                const SizedBox(height: 24),
                GlassPanel(
                  borderColor: AppColors.outlineVariant.withValues(alpha: 0.2),
                  child: Column(
                    children: [
                      const Icon(Icons.lock_outline, size: 48, color: AppColors.outline),
                      const SizedBox(height: 16),
                      Text(
                        vm.isTurkish ? 'SALT OKUNUR MOD' : 'READ-ONLY MODE',
                        style: AppTypography.labelCaps.copyWith(color: AppColors.outline, letterSpacing: 2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        vm.isTurkish 
                            ? 'Ses kaydetme ve analiz başlatma yetkiniz bulunmamaktadır. Geçmiş analizleri inceleyebilir ve ses kayıtlarını dinleyebilirsiniz.' 
                            : 'You do not have permission to record or analyze audio. You can view and listen to past analyses.',
                        style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              const SizedBox(height: 24),
              _ProcessStatusBar(vm: vm),
              const SizedBox(height: 24),
              if (vm.history.isNotEmpty) _buildLastAnalysisCard(vm),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLastAnalysisCard(AppViewModel vm) {
    final lastResult = vm.history.first;

    return GlassPanel(
      borderColor: AppColors.primaryContainer,
      borderOpacity: 0.3,
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Icon(Icons.analytics, size: 120, color: AppColors.primaryContainer.withValues(alpha: 0.08)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(vm.l10n.lastSession, style: AppTypography.labelCaps.copyWith(color: AppColors.primaryContainer)),
                  ),
                  Text(Formatters.formatRelativeTime(lastResult.date), style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 12),
              Text(lastResult.title, style: AppTypography.h2.copyWith(color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Text(
                lastResult.summary.isNotEmpty ? lastResult.summary : 'Analysis complete. Tap to view details.',
                style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              if (lastResult.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lastResult.tags.map((tag) => TagChip(label: tag)).toList(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProcessStatusBar extends StatelessWidget {
  final AppViewModel vm;
  const _ProcessStatusBar({required this.vm});

  static const _steps = ['transkript', 'analiz', 'email', 'tamamlandi'];

  @override
  Widget build(BuildContext context) {
    final state = vm.processState;
    if (state == 'idle') return const SizedBox.shrink();

    final isError = state == 'error';
    final isDone = state == 'done';
    final currentStep = isDone ? 3 : _steps.indexOf(vm.processStep);
    final stepLabels = [vm.l10n.stepTranscript, vm.l10n.stepAnalysis, vm.l10n.stepEmail, vm.l10n.stepDone];

    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 12,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            isError ? vm.l10n.errorOccurred : isDone ? vm.l10n.analysisComplete : vm.l10n.processing,
            style: AppTypography.labelCaps.copyWith(
              color: isError ? AppColors.error : isDone ? AppColors.primaryContainer : AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
          if (isError)
            const Icon(Icons.error_outline, size: 16, color: AppColors.error)
          else if (isDone)
            const Icon(Icons.check_circle, size: 16, color: AppColors.primaryContainer),
        ]),
        if (!isError && !isDone && currentStep >= 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  stepLabels[currentStep],
                  style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10),
                ),
                Text(
                  '${vm.processProgress.toInt()}%',
                  style: AppTypography.monoLg.copyWith(color: AppColors.primary, fontSize: 10),
                ),
              ]),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: vm.processProgress / 100,
                  minHeight: 4,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  color: AppColors.primary,
                ),
              ),
            ]),
          ),
        const SizedBox(height: 12),
        Row(children: List.generate(_steps.length, (i) {
          final isActive = i == currentStep && !isDone;
          final isDoneStep = isDone || i < currentStep;
          final color = isError && i == currentStep
              ? AppColors.error
              : isDoneStep
                  ? AppColors.primaryContainer
                  : isActive
                      ? AppColors.primary
                      : AppColors.outline;

          return Expanded(child: Row(children: [
            Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: isDoneStep || isActive ? 0.15 : 0.05),
                  border: Border.all(color: color, width: isDoneStep || isActive ? 1.5 : 1),
                ),
                child: Center(
                  child: isDoneStep && !isActive
                      ? Icon(Icons.check, size: 14, color: color)
                      : isActive
                          ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: color))
                          : Text('${i + 1}', style: AppTypography.labelCaps.copyWith(color: color, fontSize: 10)),
                ),
              ),
              const SizedBox(height: 4),
              Text(stepLabels[i], style: AppTypography.bodyMd.copyWith(color: color, fontSize: 9)),
            ]),
            if (i < _steps.length - 1)
              Expanded(child: Container(height: 1, margin: const EdgeInsets.only(bottom: 16), color: i < currentStep ? AppColors.primaryContainer : AppColors.outlineVariant)),
          ]));
        })),
      ]),
    );
  }
}
