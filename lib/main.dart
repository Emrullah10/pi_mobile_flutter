import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/server_config.dart';
import 'presentation/viewmodels/app_viewmodel.dart';
import 'presentation/app_shell.dart';

import 'core/theme/app_colors.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServerConfig.load();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF09090B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const WhisperPiApp());
}

class WhisperPiApp extends StatelessWidget {
  const WhisperPiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()..checkAuth()),
        ChangeNotifierProvider(create: (_) => AppViewModel()),
      ],
      child: MaterialApp(
        title: 'Whisper Pi Summary Hub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: Consumer<AuthViewModel>(
          builder: (context, authVm, _) {
            if (authVm.isLoading) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryFixedDim),
                  ),
                ),
              );
            }

            if (authVm.isAuthenticated) {
              return const AppShell();
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
