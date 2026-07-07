import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/admin/user_management_screen.dart';
import 'viewmodels/app_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';

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
  List<String> _getNavTitles(bool isAdmin, AppViewModel vm) {
    return [
      vm.l10n.navHistory,
      vm.l10n.navRecord,
      if (isAdmin) (vm.isTurkish ? 'KULLANICILAR' : 'USERS'),
      if (isAdmin) vm.l10n.navSystem,
    ];
  }

  // Rol bazlı AppBar başlıklarını döndüren yardımcı fonksiyon
  String _getAppBarTitle(bool isAdmin, AppViewModel vm) {
    if (_currentIndex == 0) return vm.l10n.titleHistory;
    if (_currentIndex == 1) return vm.l10n.titleDashboard;
    if (isAdmin) {
      if (_currentIndex == 2) return vm.isTurkish ? 'KULLANICI_YÖNETİMİ' : 'USER_MANAGEMENT';
      if (_currentIndex == 3) return vm.l10n.titleSettings;
    }
    return 'NEURAL_CORE';
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final isAdmin = authVm.isAdmin;
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
                  Consumer<AppViewModel>(
                    builder: (_, vm, _) => Icon(
                      Icons.memory,
                      color: vm.isOnline ? AppColors.primaryContainer : AppColors.zinc500,
                      size: 24,
                    ),
                  ),
                  Consumer<AppViewModel>(
                    builder: (_, vm, _) => Text(
                      _getAppBarTitle(isAdmin, vm),
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
                      if (isAdmin && vm.processState == 'processing')
                        _SpinningIcon()
                      else if (isAdmin)
                        const Icon(Icons.settings_input_component, color: AppColors.zinc500, size: 24),
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
                                    authVm.logout();
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
                  ),
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
                      Consumer<AppViewModel>(builder: (_, vm, _) => Text(
                        _getNavTitles(isAdmin, vm)[index],
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
