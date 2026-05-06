import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'viewmodels/app_viewmodel.dart';

/// App Shell — manages bottom nav + shared app bar
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _SpinningIcon extends StatefulWidget {
  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _c,
      child: const Icon(Icons.settings_input_component, color: AppColors.primaryContainer, size: 24),
    );
  }
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 1; // Start on RECORD (Dashboard)

  static const _screenBuilders = [
    HistoryScreen(),
    DashboardScreen(),
    SettingsScreen(),
  ];

  final _icons = const [Icons.storage, Icons.mic, Icons.settings_suggest];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      extendBody: true,

      // ─── Top AppBar ───
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(92),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.zinc950,
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer<AppViewModel>(
                    builder: (_, vm, _) => Icon(
                      Icons.memory,
                      color: vm.isOnline ? AppColors.primaryContainer : AppColors.zinc500,
                      size: 24,
                    ),
                  ),
                  Consumer<AppViewModel>(
                    builder: (_, vm, _) => Text(
                      _currentIndex == 0
                          ? vm.l10n.titleHistory
                          : _currentIndex == 1
                              ? vm.l10n.titleDashboard
                              : vm.l10n.titleSettings,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ),
                  Consumer<AppViewModel>(
                    builder: (_, vm, _) => Row(mainAxisSize: MainAxisSize.min, children: [
                      vm.processState == 'processing'
                          ? _SpinningIcon()
                          : const Icon(Icons.settings_input_component, color: AppColors.zinc500, size: 24),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: vm.toggleLocale,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.zinc500),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            vm.isTurkish ? 'TR' : 'EN',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ─── Body ───
      body: Padding(
        padding: EdgeInsets.only(
          top: 72,
          bottom: 80 + MediaQuery.of(context).padding.bottom,
        ),
        child: _screenBuilders[_currentIndex],
      ),

      // ─── Bottom Nav ───
      bottomNavigationBar: Container(
        height: 80 + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: AppColors.zinc950,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: List.generate(3, (index) {
              final isActive = index == _currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _currentIndex = index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _icons[index],
                        size: 24,
                        color: isActive
                            ? AppColors.primaryContainer
                            : AppColors.neutral600,
                      ),
                      const SizedBox(height: 4),
                      Consumer<AppViewModel>(builder: (_, vm, _) => Text(
                        [vm.l10n.navHistory, vm.l10n.navRecord, vm.l10n.navSystem][index],
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: isActive
                              ? AppColors.primaryContainer
                              : AppColors.neutral600,
                        ),
                      )),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 4 : 0,
                        height: isActive ? 4 : 0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
