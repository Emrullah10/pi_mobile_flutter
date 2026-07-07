import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/server_config.dart';
import '../../../data/services/discovery_service.dart';
import '../../widgets/glass_panel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _serverController = TextEditingController();
  bool _discovering = false;

  @override
  void initState() {
    super.initState();
    _serverController.text = ServerConfig.baseUrl
        .replaceFirst('http://', '')
        .replaceFirst(':3000', '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _serverController.dispose();
    super.dispose();
  }

  Future<void> _saveServer() async {
    await ServerConfig.setBaseUrl(_serverController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sunucu adresi kaydedildi.')),
      );
    }
  }

  Future<void> _autoDiscover() async {
    setState(() => _discovering = true);
    final ip = await DiscoveryService().discoverPiIp();
    if (!mounted) return;
    if (ip != null) {
      await ServerConfig.setBaseUrl(ip);
      _serverController.text = ip;
    }
    if (!mounted) return;
    setState(() => _discovering = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ip != null ? 'Pi bulundu: $ip' : 'Pi ağda bulunamadı (whisperpi.local)')),
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authVm = context.read<AuthViewModel>();
    final success = await authVm.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Giriş başarılı. Sisteme bağlanıldı.', style: AppTypography.bodyMd),
            backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.8),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authVm.errorMessage ?? 'Giriş yapılamadı.', style: AppTypography.bodyMd),
            backgroundColor: AppColors.error.withValues(alpha: 0.8),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Arka Plan Işık Efektleri (Blur daireler)
          Positioned(
            top: -100,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryFixedDim.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          // Ana İçerik
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Üst Logo ve Başlık
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceContainerLowest,
                              border: Border.all(color: AppColors.primaryFixedDim.withValues(alpha: 0.3)),
                            ),
                            child: const Icon(
                              Icons.security,
                              size: 40,
                              color: AppColors.primaryFixedDim,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'VOX_OS_INTELLIGENCE',
                            style: AppTypography.labelCaps.copyWith(
                              color: AppColors.primaryFixedDim,
                              fontSize: 13,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Summary Hub',
                            style: AppTypography.h1.copyWith(
                              color: AppColors.onBackground,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Sunucu Adresi Kartı
                    GlassPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SUNUCU ADRESİ',
                            style: AppTypography.labelCaps.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _serverController,
                                  style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                                  decoration: InputDecoration(
                                    hintText: '192.168.1.39',
                                    hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                                    prefixIcon: const Icon(Icons.router_outlined, color: AppColors.outline, size: 18),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppColors.outlineVariant),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppColors.outlineVariant),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppColors.primaryContainer),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _saveServer,
                                icon: const Icon(Icons.check, color: AppColors.primaryFixedDim),
                                tooltip: 'Kaydet',
                              ),
                              if (_discovering)
                                const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(AppColors.primaryFixedDim)),
                                )
                              else
                                IconButton(
                                  onPressed: _autoDiscover,
                                  icon: const Icon(Icons.wifi_find_outlined, color: AppColors.primaryFixedDim),
                                  tooltip: 'Otomatik Bul',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Glassmorphic Giriş Paneli
                    GlassPanel(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'GİRİŞ YAPIN',
                            style: AppTypography.labelCaps.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // E-posta alanı
                          TextFormField(
                            controller: _emailController,
                            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'E-Posta Adresi',
                              labelStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                              prefixIcon: const Icon(Icons.alternate_email, color: AppColors.outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.outlineVariant),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.outlineVariant),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.primaryContainer),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Lütfen e-posta adresinizi girin.';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value.trim())) {
                                return 'Geçersiz e-posta formatı.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Şifre alanı
                          TextFormField(
                            controller: _passwordController,
                            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              labelStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.outline,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.outlineVariant),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.outlineVariant),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.primaryContainer),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen şifrenizi girin.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Giriş Butonu
                          ElevatedButton(
                            onPressed: authVm.isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: authVm.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : Text(
                                    'SİSTEME BAĞLAN',
                                    style: AppTypography.labelCaps.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
