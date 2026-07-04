import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/main_shell.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/profile_models.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../../core/utils/error_parser.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _showPasswords = false;
  bool _isChangingPassword = false;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final old = _oldPasswordCtrl.text.trim();
    final newPass = _newPasswordCtrl.text.trim();
    final confirm = _confirmPasswordCtrl.text.trim();

    if (old.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showSnack('Please fill all password fields', isError: true);
      return;
    }
    if (newPass.length < 6) {
      _showSnack('New password must be at least 6 characters', isError: true);
      return;
    }
    if (newPass != confirm) {
      _showSnack('Passwords do not match', isError: true);
      return;
    }

    setState(() => _isChangingPassword = true);
    try {
      final remote = ref.read(settingsRemoteSourceProvider);
      await remote.changePassword(old, newPass);
      _oldPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();
      _showSnack('Password changed successfully');
    } catch (e) {
      _showSnack(extractError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isChangingPassword = false);
    }
  }

  Future<void> _showVerifyEmailDialog() async {
    final remote = ref.read(settingsRemoteSourceProvider);
    bool otpSent = false;
    bool sending = false;
    bool confirming = false;
    String? errorMsg;
    final otpCtrl = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DialogControllerManager(
        controllers: [otpCtrl],
        child: StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.border),
          ),
          title: const Text('Verify Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!otpSent)
                Text(
                  'We will send a 6-digit OTP to your registered email address.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              if (otpSent) ...[
                Text(
                  'Enter the 6-digit OTP sent to your email:',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: '------',
                    counterText: '',
                  ),
                ),
              ],
              if (errorMsg != null) ...[
                const SizedBox(height: 8),
                Text(errorMsg!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
              if (sending || confirming) ...[
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            if (!otpSent)
              FilledButton(
                onPressed: sending
                    ? null
                    : () async {
                        setDialogState(() {
                          sending = true;
                          errorMsg = null;
                        });
                        try {
                          await remote.sendEmailOtp();
                          setDialogState(() {
                            otpSent = true;
                            sending = false;
                          });
                        } catch (e) {
                          setDialogState(() {
                            errorMsg = extractError(e);
                            sending = false;
                          });
                        }
                      },
                child: const Text('Send OTP'),
              ),
            if (otpSent)
              FilledButton(
                onPressed: confirming
                    ? null
                    : () async {
                        if (otpCtrl.text.trim().length != 6) {
                          setDialogState(() => errorMsg = 'Enter the 6-digit OTP');
                          return;
                        }
                        setDialogState(() {
                          confirming = true;
                          errorMsg = null;
                        });
                        try {
                          await remote.confirmEmailOtp(otpCtrl.text.trim());
                          if (ctx.mounted) Navigator.pop(ctx);
                          ref.invalidate(profileNotifierProvider);
                          _showSnack('Email verified successfully');
                        } catch (e) {
                          setDialogState(() {
                            errorMsg = extractError(e);
                            confirming = false;
                          });
                        }
                      },
                child: const Text('Verify'),
              ),
          ],
        ),
      ),
    ),
  );
  }

  Future<void> _showVerifyPhoneDialog() async {
    final remote = ref.read(settingsRemoteSourceProvider);
    bool otpSent = false;
    bool sending = false;
    bool confirming = false;
    String? errorMsg;
    final otpCtrl = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DialogControllerManager(
        controllers: [otpCtrl],
        child: StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.border),
          ),
          title: const Text('Verify Phone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!otpSent)
                Text(
                  'We will send a 6-digit OTP to your registered phone number.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              if (otpSent) ...[
                Text(
                  'Enter the 6-digit OTP sent to your phone:',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: '------',
                    counterText: '',
                  ),
                ),
              ],
              if (errorMsg != null) ...[
                const SizedBox(height: 8),
                Text(errorMsg!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
              if (sending || confirming) ...[
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            if (!otpSent)
              FilledButton(
                onPressed: sending
                    ? null
                    : () async {
                        setDialogState(() {
                          sending = true;
                          errorMsg = null;
                        });
                        try {
                          await remote.sendPhoneOtp();
                          setDialogState(() {
                            otpSent = true;
                            sending = false;
                          });
                        } catch (e) {
                          setDialogState(() {
                            errorMsg = extractError(e);
                            sending = false;
                          });
                        }
                      },
                child: const Text('Send OTP'),
              ),
            if (otpSent)
              FilledButton(
                onPressed: confirming
                    ? null
                    : () async {
                        if (otpCtrl.text.trim().length != 6) {
                          setDialogState(() => errorMsg = 'Enter the 6-digit OTP');
                          return;
                        }
                        setDialogState(() {
                          confirming = true;
                          errorMsg = null;
                        });
                        try {
                          await remote.confirmPhoneOtp(otpCtrl.text.trim());
                          if (ctx.mounted) Navigator.pop(ctx);
                          ref.invalidate(profileNotifierProvider);
                          _showSnack('Phone verified successfully');
                        } catch (e) {
                          setDialogState(() {
                            errorMsg = extractError(e);
                            confirming = false;
                          });
                        }
                      },
                child: const Text('Verify'),
              ),
          ],
        ),
      ),
    ),
  );
  }


  Future<void> _showEditEmailDialog(VendorProfile profile) async {
    final remote = ref.read(settingsRemoteSourceProvider);
    final emailCtrl = TextEditingController(text: profile.email);
    bool otpSent = false;
    bool sending = false;
    bool confirming = false;
    String? errorMsg;
    final otpCtrl = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DialogControllerManager(
        controllers: [emailCtrl, otpCtrl],
        child: StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.border),
          ),
          title: const Text('Edit Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!otpSent) ...[
                Text(
                  'Enter your new email address. We will send a verification OTP to it.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'New Email',
                    hintText: 'Enter new email',
                  ),
                ),
              ] else ...[
                Text(
                  'Enter the 6-digit OTP sent to ${emailCtrl.text.trim()}:',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: '------',
                    counterText: '',
                  ),
                ),
              ],
              if (errorMsg != null) ...[
                const SizedBox(height: 8),
                Text(errorMsg!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
              if (sending || confirming) ...[
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            if (!otpSent)
              FilledButton(
                onPressed: sending
                    ? null
                    : () async {
                        final email = emailCtrl.text.trim();
                        if (email.isEmpty) {
                          setDialogState(() => errorMsg = 'Email cannot be empty');
                          return;
                        }
                        setDialogState(() {
                          sending = true;
                          errorMsg = null;
                        });
                        try {
                          await remote.sendEmailOtp(email: email);
                          setDialogState(() {
                            otpSent = true;
                            sending = false;
                          });
                        } catch (e) {
                          setDialogState(() {
                            errorMsg = extractError(e);
                            sending = false;
                          });
                        }
                      },
                child: const Text('Send OTP'),
              ),
            if (otpSent)
              FilledButton(
                onPressed: confirming
                    ? null
                    : () async {
                        final otp = otpCtrl.text.trim();
                        if (otp.length != 6) {
                          setDialogState(() => errorMsg = 'Enter the 6-digit OTP');
                          return;
                        }
                        setDialogState(() {
                          confirming = true;
                          errorMsg = null;
                        });
                        try {
                          await remote.confirmEmailOtp(otp);
                          await ref
                              .read(profileNotifierProvider.notifier)
                              .save({'email': emailCtrl.text.trim()});
                          if (ctx.mounted) Navigator.pop(ctx);
                          _showSnack('Email updated successfully');
                        } catch (e) {
                          setDialogState(() {
                            errorMsg = extractError(e);
                            confirming = false;
                          });
                        }
                      },
                child: const Text('Verify & Save'),
              ),
          ],
        ),
      ),
    ),
  );
  }

  Future<void> _showEditPhoneDialog(VendorProfile profile) async {
    final remote = ref.read(settingsRemoteSourceProvider);
    final phoneCtrl = TextEditingController(text: profile.phone);
    bool otpSent = false;
    bool sending = false;
    bool confirming = false;
    String? errorMsg;
    final otpCtrl = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DialogControllerManager(
        controllers: [phoneCtrl, otpCtrl],
        child: StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.border),
          ),
          title: const Text('Edit Phone Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!otpSent) ...[
                Text(
                  'Enter your new phone number. We will send a verification OTP to it.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'New Phone',
                    hintText: 'Enter new phone number',
                  ),
                ),
              ] else ...[
                Text(
                  'Enter the 6-digit OTP sent to ${phoneCtrl.text.trim()}:',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: '------',
                    counterText: '',
                  ),
                ),
              ],
              if (errorMsg != null) ...[
                const SizedBox(height: 8),
                Text(errorMsg!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
              if (sending || confirming) ...[
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            if (!otpSent)
              FilledButton(
                onPressed: sending
                    ? null
                    : () async {
                        final phone = phoneCtrl.text.trim();
                        if (phone.isEmpty) {
                          setDialogState(() => errorMsg = 'Phone number cannot be empty');
                          return;
                        }
                        setDialogState(() {
                          sending = true;
                          errorMsg = null;
                        });
                        try {
                          await remote.sendPhoneOtp(phone: phone);
                          setDialogState(() {
                            otpSent = true;
                            sending = false;
                          });
                        } catch (e) {
                          setDialogState(() {
                            errorMsg = extractError(e);
                            sending = false;
                          });
                        }
                      },
                child: const Text('Send OTP'),
              ),
            if (otpSent)
              FilledButton(
                onPressed: confirming
                    ? null
                    : () async {
                        final otp = otpCtrl.text.trim();
                        if (otp.length != 6) {
                          setDialogState(() => errorMsg = 'Enter the 6-digit OTP');
                          return;
                        }
                        setDialogState(() {
                          confirming = true;
                          errorMsg = null;
                        });
                        try {
                          await remote.confirmPhoneOtp(otp);
                          await ref
                              .read(profileNotifierProvider.notifier)
                              .save({'phone': phoneCtrl.text.trim()});
                          if (ctx.mounted) Navigator.pop(ctx);
                          _showSnack('Phone updated successfully');
                        } catch (e) {
                          setDialogState(() {
                            errorMsg = extractError(e);
                            confirming = false;
                          });
                        }
                      },
                child: const Text('Verify & Save'),
              ),
          ],
        ),
      ),
    ),
  );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(isDarkModeProvider);
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Settings'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(
              title: 'Settings',
              subtitle: 'Account access and session controls',
            ),
            const SizedBox(height: 16),
            const _AppearanceCard(),
            const SizedBox(height: 16),
            _PersonalDetailsCard(
              profile: profile,
              onVerifyEmail: _showVerifyEmailDialog,
              onVerifyPhone: _showVerifyPhoneDialog,
              onEditEmail: () => _showEditEmailDialog(profile),
              onEditPhone: () => _showEditPhoneDialog(profile),
            ),
            const SizedBox(height: 16),
            _ChangePasswordCard(
              oldPasswordCtrl: _oldPasswordCtrl,
              newPasswordCtrl: _newPasswordCtrl,
              confirmPasswordCtrl: _confirmPasswordCtrl,
              showPasswords: _showPasswords,
              isLoading: _isChangingPassword,
              onToggleShowPasswords: () =>
                  setState(() => _showPasswords = !_showPasswords),
              onChangePassword: _changePassword,
            ),
            const SizedBox(height: 16),
            _SessionCard(
              onLogout: () async {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) context.go(RouteNames.login);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}

// ─── Settings Card Shell ───────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─── Appearance Card ───────────────────────────────────────────────────────────

class _AppearanceCard extends ConsumerWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider).valueOrNull ?? ThemeMode.system;

    return _SettingsCard(
      title: 'Appearance',
      subtitle: 'Choose how the app looks',
      child: Row(
        children: ThemeMode.values.map((mode) {
          final selected = mode == themeMode;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: mode == ThemeMode.values.last ? 0 : 8),
              child: GestureDetector(
                onTap: () => ref.read(themeModeNotifierProvider.notifier).setThemeMode(mode),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryGlow : AppColors.surface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        switch (mode) {
                          ThemeMode.system => Icons.brightness_auto_outlined,
                          ThemeMode.light => Icons.light_mode_outlined,
                          ThemeMode.dark => Icons.dark_mode_outlined,
                        },
                        size: 20,
                        color: selected ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        switch (mode) {
                          ThemeMode.system => 'System',
                          ThemeMode.light => 'Light',
                          ThemeMode.dark => 'Dark',
                        },
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Personal Details Card ─────────────────────────────────────────────────────

class _PersonalDetailsCard extends StatelessWidget {
  final VendorProfile profile;
  final VoidCallback onVerifyEmail;
  final VoidCallback onVerifyPhone;
  final VoidCallback onEditEmail;
  final VoidCallback onEditPhone;

  const _PersonalDetailsCard({
    required this.profile,
    required this.onVerifyEmail,
    required this.onVerifyPhone,
    required this.onEditEmail,
    required this.onEditPhone,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Personal Details',
      subtitle: 'Your email and contact number',

      child: Column(
        children: [
          _DetailRow(
            label: 'Email',
            value: profile.email ?? '',
            verified: profile.isEmailVerified,
            onVerify: profile.isEmailVerified ?? false ? null : onVerifyEmail,
            onEdit: onEditEmail,
          ),
          const _RowDivider(),
          _DetailRow(
            label: 'Phone',
            value: profile.phone ?? '',
            verified: profile.isPhoneVerified,
            onVerify: profile.isPhoneVerified ?? false ? null : onVerifyPhone,
            onEdit: onEditPhone,
          ),

        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(color: AppColors.border, height: 1, thickness: 1);
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool? verified;
  final VoidCallback? onVerify;
  final VoidCallback? onEdit;

  const _DetailRow({
    required this.label,
    required this.value,
    this.verified,
    this.onVerify,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onEdit != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (verified != null) ...[
            const SizedBox(width: 8),
            if (verified!)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 12, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cancel, size: 12, color: AppColors.warning),
                    SizedBox(width: 4),
                    Text(
                      'Unverified',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onVerify != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onVerify,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGlow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: const Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

// ─── Change Password Card ──────────────────────────────────────────────────────

class _ChangePasswordCard extends StatelessWidget {
  final TextEditingController oldPasswordCtrl;
  final TextEditingController newPasswordCtrl;
  final TextEditingController confirmPasswordCtrl;
  final bool showPasswords;
  final bool isLoading;
  final VoidCallback onToggleShowPasswords;
  final VoidCallback onChangePassword;

  const _ChangePasswordCard({
    required this.oldPasswordCtrl,
    required this.newPasswordCtrl,
    required this.confirmPasswordCtrl,
    required this.showPasswords,
    required this.isLoading,
    required this.onToggleShowPasswords,
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Change Password',
      subtitle: 'Update your login password',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PasswordField(
            controller: oldPasswordCtrl,
            label: 'Current Password',
            hint: 'Enter current password',
            obscure: !showPasswords,
          ),
          const SizedBox(height: 12),
          _PasswordField(
            controller: newPasswordCtrl,
            label: 'New Password',
            hint: 'Minimum 6 characters',
            obscure: !showPasswords,
          ),
          const SizedBox(height: 12),
          _PasswordField(
            controller: confirmPasswordCtrl,
            label: 'Confirm New Password',
            hint: 'Repeat new password',
            obscure: !showPasswords,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onToggleShowPasswords,
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: showPasswords,
                    onChanged: (_) => onToggleShowPasswords(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Show passwords',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isLoading ? null : onChangePassword,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Change Password'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// ─── Session Card ──────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final VoidCallback onLogout;

  const _SessionCard({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Sign out from this device',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Text(
            'Logging out will clear your current vendor session and send you back to the login page.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _DialogControllerManager extends StatefulWidget {
  final List<TextEditingController> controllers;
  final Widget child;

  const _DialogControllerManager({
    required this.controllers,
    required this.child,
  });

  @override
  State<_DialogControllerManager> createState() => _DialogControllerManagerState();
}

class _DialogControllerManagerState extends State<_DialogControllerManager> {
  @override
  void dispose() {
    for (final controller in widget.controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
