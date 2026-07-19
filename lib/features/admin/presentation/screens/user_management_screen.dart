import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/user.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminUsersProvider.notifier).fetchUsers();
    });
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          String selectedRole = 'user';
          return AlertDialog(
            backgroundColor: AppColors.zinc950,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.glassBorder),
            ),
            title: Text(
              'YENİ KULLANICI EKLE',
              style: AppTypography.labelCaps.copyWith(
                color: AppColors.primaryContainer,
                letterSpacing: 2,
              ),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'İsim Soyisim',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'İsim gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'E-Posta',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'E-posta gerekli' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (v) =>
                          v == null || v.length < 6 ? 'Şifre en az 6 karakter olmalı' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      dropdownColor: AppColors.zinc950,
                      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text('Kullanıcı (Salt Okunur)')),
                        DropdownMenuItem(value: 'admin', child: Text('Yönetici (Admin)')),
                      ],
                      onChanged: (v) => setDialogState(() => selectedRole = v ?? 'user'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('İPTAL',
                    style: AppTypography.labelCaps.copyWith(color: AppColors.zinc500)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final adminNotifier = ref.read(adminUsersProvider.notifier);
                  final success = await adminNotifier.createUser(
                        emailController.text.trim(),
                        nameController.text.trim(),
                        passwordController.text,
                        selectedRole,
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kullanıcı oluşturuldu.')),
                      );
                    } else {
                      final err = adminNotifier.errorMessage;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err ?? 'Hata oluştu.')),
                      );
                    }
                  }
                },
                child: Text('EKLE',
                    style: AppTypography.labelCaps.copyWith(color: Colors.black)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditUserDialog(User user) {
    final nameController = TextEditingController(text: user.name);
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          String selectedRole = user.role;
          return AlertDialog(
            backgroundColor: AppColors.zinc950,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.glassBorder),
            ),
            title: Text(
              'KULLANICIYI DÜZENLE',
              style: AppTypography.labelCaps.copyWith(
                color: AppColors.primaryContainer,
                letterSpacing: 2,
              ),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'İsim Soyisim',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'İsim gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Yeni Şifre (Boş bırakılabilir)',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    dropdownColor: AppColors.zinc950,
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'Rol',
                      prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('Kullanıcı (Salt Okunur)')),
                      DropdownMenuItem(value: 'admin', child: Text('Yönetici (Admin)')),
                    ],
                    onChanged: (v) => setDialogState(() => selectedRole = v ?? 'user'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('İPTAL',
                    style: AppTypography.labelCaps.copyWith(color: AppColors.zinc500)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final adminNotifier = ref.read(adminUsersProvider.notifier);
                  final success = await adminNotifier.updateUserDetails(
                        user.id,
                        name: nameController.text.trim(),
                        role: selectedRole,
                        password: passwordController.text.isEmpty ? null : passwordController.text,
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kullanıcı güncellendi.')),
                      );
                    } else {
                      final err = adminNotifier.errorMessage;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err ?? 'Hata oluştu.')),
                      );
                    }
                  }
                },
                child: Text('GÜNCELLE',
                    style: AppTypography.labelCaps.copyWith(color: Colors.black)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminUsersState = ref.watch(adminUsersProvider);
    final currentUser = ref.watch(authNotifierProvider).valueOrNull;
    final users = adminUsersState.valueOrNull ?? [];
    final isLoading = adminUsersState.isLoading;
    final adminCount = users.where((u) => u.isAdmin).length;
    final userCount = users.where((u) => u.isUser).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: isLoading && users.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryFixedDim),
              ),
            )
          : Column(
              children: [
                // Özet satırı
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: GlassPanel(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        _StatChip(
                          label: 'TOPLAM',
                          value: users.length.toString(),
                          color: AppColors.onSurface,
                        ),
                        const SizedBox(width: 24),
                        _StatChip(
                          label: 'ADMIN',
                          value: adminCount.toString(),
                          color: AppColors.primaryContainer,
                        ),
                        const SizedBox(width: 24),
                        _StatChip(
                          label: 'KULLANICI',
                          value: userCount.toString(),
                          color: AppColors.zinc500,
                        ),
                      ],
                    ),
                  ),
                ),
                // Liste
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primaryFixedDim,
                    onRefresh: () => ref.read(adminUsersProvider.notifier).fetchUsers(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                      itemCount: users.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final isCurrentUser = user.id == currentUser?.id;

                        return GlassPanel(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                backgroundColor: user.isAdmin
                                    ? AppColors.primaryFixedDim.withValues(alpha: 0.2)
                                    : AppColors.surfaceContainerLowest,
                                child: Icon(
                                  user.isAdmin
                                      ? Icons.admin_panel_settings
                                      : Icons.person,
                                  color: user.isAdmin
                                      ? AppColors.primaryFixedDim
                                      : AppColors.outline,
                                ),
                              ),
                              const SizedBox(width: 14),
                              // İsim + email + badge'ler
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            user.name,
                                            style: AppTypography.h3.copyWith(
                                              color: user.isActive
                                                  ? AppColors.onSurface
                                                  : AppColors.zinc500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        _RoleBadge(role: user.role),
                                        if (isCurrentUser) ...[
                                          const SizedBox(width: 4),
                                          _MeBadge(),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      user.email,
                                      style: AppTypography.bodyMd.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Aktif toggle
                              if (!isCurrentUser)
                                Switch(
                                  value: user.isActive,
                                  activeThumbColor: AppColors.primaryFixedDim,
                                  onChanged: (val) {
                                    ref.read(adminUsersProvider.notifier).updateUserDetails(user.id, isActive: val);
                                  },
                                ),
                              // Düzenle
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.outline, size: 20),
                                onPressed: () => _showEditUserDialog(user),
                              ),
                              // Sil
                              if (!isCurrentUser)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                  onPressed: () => _confirmDelete(context, ref, user),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.black,
        onPressed: _showAddUserDialog,
        child: const Icon(Icons.person_add_alt_1_outlined),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.zinc950,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text(
          'KULLANICIY SİL',
          style: AppTypography.labelCaps.copyWith(color: AppColors.error),
        ),
        content: Text(
          '${user.name} kullanıcısını silmek istediğinize emin misiniz?',
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İPTAL',
                style: AppTypography.labelCaps.copyWith(color: AppColors.zinc500)),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref.read(adminUsersProvider.notifier).deleteUser(user.id);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kullanıcı silindi.')),
                  );
                }
              }
            },
            child: Text('SİL',
                style: AppTypography.labelCaps.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isAdmin
            ? AppColors.primaryContainer.withValues(alpha: 0.15)
            : AppColors.zinc600.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isAdmin
              ? AppColors.primaryContainer.withValues(alpha: 0.4)
              : AppColors.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Text(
        isAdmin ? 'ADMIN' : 'USER',
        style: AppTypography.mono.copyWith(
          color: isAdmin ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
          fontSize: 8,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _MeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryFixedDim.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'SİZ',
        style: AppTypography.mono.copyWith(
          color: AppColors.primaryFixedDim,
          fontSize: 8,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.h3.copyWith(color: color, fontSize: 20),
        ),
        Text(
          label,
          style: AppTypography.mono.copyWith(color: AppColors.zinc500, fontSize: 9),
        ),
      ],
    );
  }
}
