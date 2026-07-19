import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/analysis_result.dart';
import '../providers/history_providers.dart';
import '../widgets/waveform_visualizer.dart';
import '../widgets/tag_chip.dart';
import '../../../analysis/presentation/screens/analysis_detail_screen.dart';

/// History Screen — List of past recordings with search
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';
  String? _activeFilter;

  static const _filterOptions = ['toplanti', 'ders', 'proje', 'genel'];

  void _showFilterSheet(BuildContext context) {
    final l10n = ref.read(l10nProvider);
    final filterLabels = [l10n.catMeeting, l10n.catLesson, l10n.catProject, l10n.catGeneral];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l10n.categoryFilter, style: AppTypography.labelCaps.copyWith(color: AppColors.primary, letterSpacing: 2)),
              if (_activeFilter != null)
                TextButton(
                  onPressed: () { setState(() => _activeFilter = null); Navigator.pop(ctx); },
                  child: Text(l10n.clear, style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                ),
            ]),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: List.generate(_filterOptions.length, (i) {
              final isActive = _activeFilter == _filterOptions[i];
              return GestureDetector(
                onTap: () {
                  setState(() => _activeFilter = isActive ? null : _filterOptions[i]);
                  Navigator.pop(ctx);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isActive ? AppColors.primary : AppColors.outlineVariant),
                  ),
                  child: Text(filterLabels[i], style: AppTypography.labelCaps.copyWith(color: isActive ? AppColors.primary : AppColors.onSurfaceVariant)),
                ),
              );
            })),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final historyAsync = ref.watch(historyProvider);
    final isLoading = historyAsync.isLoading;
    final history = historyAsync.valueOrNull ?? [];

    final filteredHistory = history.where((r) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.tags.any((t) => t.toLowerCase().contains(q));
      final matchesFilter = _activeFilter == null ||
          r.tags.any((t) => t.toLowerCase() == _activeFilter);
      return matchesSearch && matchesFilter;
    }).toList();

    return RefreshIndicator(
      onRefresh: ref.read(historyProvider.notifier).refreshHistory,
      color: AppColors.primaryContainer,
      backgroundColor: AppColors.surfaceContainer,
      child: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _buildSearchBar(l10n),
            ),
          ),

          // Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recentScans,
                    style: AppTypography.h3.copyWith(color: AppColors.onSurface),
                  ),
                  Text(
                    '${filteredHistory.length} ${l10n.items}',
                    style: AppTypography.labelCaps.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
                height: 1,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // History Cards
          if (isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    color: AppColors.primaryContainer,
                  ),
                ),
              ),
            )
          else if (filteredHistory.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.graphic_eq,
                        size: 64,
                        color: AppColors.outlineVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? l10n.noRecordingsYet
                            : l10n.noResults,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _HistoryCard(
                        result: filteredHistory[index],
                        isFirst: index == 0,
                      ),
                    );
                  },
                  childCount: filteredHistory.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 20),
          ),
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: false,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showFilterSheet(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _activeFilter != null ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _activeFilter != null ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Icon(Icons.tune, size: 16, color: _activeFilter != null ? AppColors.primary : AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual history card with light-leak effect, waveform, and tags
class _HistoryCard extends StatelessWidget {
  final AnalysisResult result;
  final bool isFirst;

  const _HistoryCard({required this.result, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AnalysisDetailScreen(result: result),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Light leak effect — top edge
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Light leak — left edge
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: Container(
                width: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.title,
                            style: AppTypography.h3.copyWith(
                              color: AppColors.primaryFixed,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 14, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(
                                Formatters.formatDateShort(result.date),
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Duration badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule,
                              size: 14, color: AppColors.primaryContainer),
                          const SizedBox(width: 6),
                          Text(
                            Formatters.formatDurationShort(result.duration),
                            style: AppTypography.labelCaps.copyWith(
                              color: AppColors.onSurface,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Waveform
                WaveformVisualizer(
                  isActive: isFirst,
                  activeColor: isFirst
                      ? AppColors.primaryContainer
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(height: 16),

                // Tags
                if (result.tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        result.tags.map((t) => TagChip(label: t)).toList(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
