import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/l10n/app_localizations.dart';
import '../core/providers/locale_provider.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/history/presentation/screens/history_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/admin/presentation/screens/user_management_screen.dart';

/// App Shell — manages bottom nav + shared app bar
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
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

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 1; // Start on RECORD (Dashboard)

  // Rol bazlı ekranları döndüren yardımcı fonksiyon
  List<Widget> _getScreens(bool isAdmin) {
    return [
      const HistoryScreen(),
      const DashboardScreen(),
      if (isAdmin) const UserManagementScreen(),
      if (isAdmin) const SettingsScreen(),
    ];
  }

  // Rol bazlı ikonları döndüren yardımcı fonksiyon
  List<IconData> _getIcons(bool isAdmin) {
    return [
      Icons.storage,
      Icons.mic,
      if (isAdmin) Icons.people_outline,
      if (isAdmin) Icons.settings_suggest,
    ];
  }

  // Rol bazlı menü başlıklarını döndüren yardımcı fonksiyon
  List<String> _getNavTitles(bool isAdmin, AppLocalizations l10n, bool isTurkish) {
    return [
      l10n.navHistory,
      l10n.navRecord,
      if (isAdmin) (isTurkish ? 'KULLANICILAR' : 'USERS'),
      if (isAdmin) l10n.navSystem,
    ];
  }

  // Rol bazlı AppBar başlıklarını döndüren yardımcı fonksiyon
  String _getAppBarTitle(bool isAdmin, AppLocalizations l10n, bool isTurkish) {
    if (_currentIndex == 0) return l10n.titleHistory;
    if (_currentIndex == 1) return l10n.titleDashboard;
    if (isAdmin) {
      if (_currentIndex == 2) return isTurkish ? 'KULLANICI_YÖNETİMİ' : 'USER_MANAGEMENT';
      if (_currentIndex == 3) return l10n.titleSettings;
    }
    return 'NEURAL_CORE';
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final processState = ref.watch(processStatusProvider).state;
    final l10n = ref.watch(l10nProvider);
    final isTurkish = ref.watch(localeProvider);
    final screens = _getScreens(isAdmin);
    final icons = _getIcons(isAdmin);

    // Eğer rol değişirse ve mevcut indeks sınır dışı kalırsa sıfırla
    if (_currentIndex >= screens.length) {
      _currentIndex = 1;
    }

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
                  Icon(
                    Icons.memory,
                    color: isOnline ? AppColors.primaryContainer : AppColors.zinc500,
                    size: 24,
                  ),
                  Text(
                    _getAppBarTitle(isAdmin, l10n, isTurkish),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    if (isAdmin && processState == 'processing')
                      _SpinningIcon()
                    else if (isAdmin)
                      const Icon(Icons.settings_input_component, color: AppColors.zinc500, size: 24),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => ref.read(localeProvider.notifier).toggle(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.zinc500),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isTurkish ? 'TR' : 'EN',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Çıkış Butonu
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.zinc950,
                            title: const Text('Oturumu Kapat'),
                            content: const Text('Sistem bağlantısını kesmek istediğinize emin misiniz?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('İPTAL'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ref.read(authNotifierProvider.notifier).logout();
                                },
                                child: const Text('ÇIKIŞ', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.error.withValues(alpha: 0.05),
                        ),
                        child: const Icon(
                          Icons.power_settings_new,
                          size: 16,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),

      // ─── Body ───
      // IndexedStack: sekme geçişlerinde ekranlar yeniden oluşturulmaz,
      // state korunur, initState yalnızca bir kez çalışır. Bu, Kullanıcılar
      // sekmesine hızlı tıklamada oluşan yeniden-build/crash sorununu önler.
      body: Padding(
        padding: EdgeInsets.only(
          top: 72,
          bottom: 80 + MediaQuery.of(context).padding.bottom,
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
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
            children: List.generate(screens.length, (index) {
              final isActive = index == _currentIndex;
              final navTitles = _getNavTitles(isAdmin, l10n, isTurkish);
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _currentIndex = index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[index],
                        size: 24,
                        color: isActive
                            ? AppColors.primaryContainer
                            : AppColors.neutral600,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        navTitles[index],
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: isActive
                              ? AppColors.primaryContainer
                              : AppColors.neutral600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 4 : 0,
                        height: isActive ? 4 : 0,
                        decoration: const BoxDecoration(
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
