import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/main_shell.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/last_updated_chip.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _editing = false;
  bool _saving = false;
  bool _initialized = false;

  String _originalEmail = '';
  String _originalPhone = '';

  // Edit-mode: track inline change + verification
  bool _emailChangedAndUnverified = false;
  bool _phoneChangedAndUnverified = false;
  bool _emailVerifiedInSession = false;
  bool _phoneVerifiedInSession = false;

  // View-mode: optimistic hide of Verify button after OTP success
  bool _emailVerified = false;
  bool _phoneVerified = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _startEdit(String name, String email, String phone) {
    _nameCtrl.text = name;
    _emailCtrl.text = email;
    _phoneCtrl.text = phone;
    _originalEmail = email;
    _originalPhone = phone;
    _emailChangedAndUnverified = false;
    _phoneChangedAndUnverified = false;
    _emailVerifiedInSession = false;
    _phoneVerifiedInSession = false;
    setState(() => _editing = true);
  }

  void _cancelEdit() => setState(() => _editing = false);

  // ── Inline verify: save new email → OTP dialog → revert on cancel ──────────

  Future<void> _verifyNewEmail() async {
    final remote = ref.read(settingsRemoteSourceProvider);
    final newEmail = _emailCtrl.text.trim();
    final ok = await _showOtpDialog(
      title: 'Verify New Email',
      description: 'An OTP will be sent to $newEmail',
      sendOtp: () => remote.sendEmailOtp(email: newEmail),
      confirmOtp: remote.confirmEmailOtp,
    );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _emailVerifiedInSession = true;
        _emailChangedAndUnverified = false;
      });
    }
  }

  Future<void> _verifyNewPhone() async {
    final remote = ref.read(settingsRemoteSourceProvider);
    final ok = await _showOtpDialog(
      title: 'Verify New Phone',
      description: 'An OTP will be sent to ${_phoneCtrl.text.trim()}',
      sendOtp: remote.sendPhoneOtp,
      confirmOtp: remote.confirmPhoneOtp,
    );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _phoneVerifiedInSession = true;
        _phoneChangedAndUnverified = false;
      });
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_emailChangedAndUnverified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your new email first')),
      );
      return;
    }
    if (_phoneChangedAndUnverified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your new phone first')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(profileNotifierProvider.notifier).save({
        'business_name': _nameCtrl.text.trim(),
        'business_email': _emailCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'business_phone': _phoneCtrl.text.trim(),
      });
      setState(() => _editing = false);
      ref.invalidate(profileNotifierProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── OTP dialog (reusable) ──────────────────────────────────────────────────

  Future<bool> _showOtpDialog({
    required String title,
    required String description,
    required Future<void> Function() sendOtp,
    required Future<void> Function(String) confirmOtp,
  }) async {
    bool otpSent = false;
    bool sending = false;
    bool confirming = false;
    bool verified = false;
    String? errorMsg;
    final otpCtrl = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.border),
          ),
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!otpSent)
                  Text(description,
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 13)),
                if (otpSent) ...[
                  Text('Enter the 6-digit OTP:',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 13)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: otpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    autofocus: true,
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
                  Text(errorMsg!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 13)),
                ],
                if (sending || confirming) ...[
                  const SizedBox(height: 12),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: (sending || confirming) ? null : () => Navigator.pop(ctx),
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
                          await sendOtp();
                          setDialogState(() {
                            otpSent = true;
                            sending = false;
                          });
                        } catch (e) {
                          setDialogState(() {
                            errorMsg = e.toString();
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
                          setDialogState(
                              () => errorMsg = 'Enter the 6-digit OTP');
                          return;
                        }
                        setDialogState(() {
                          confirming = true;
                          errorMsg = null;
                        });
                        try {
                          await confirmOtp(otpCtrl.text.trim());
                          verified = true;
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          setDialogState(() {
                            errorMsg = e.toString();
                            confirming = false;
                          });
                        }
                      },
                child: const Text('Verify'),
              ),
          ],
        ),
      ),
    );

    return verified;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.watch(isDarkModeProvider);
    final profileAsync = ref.watch(profileNotifierProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainShell.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Profile'),
        actions: [
          LastUpdatedChip(
            lastUpdated: notifier.lastUpdated,
            isRefreshing: profileAsync.isLoading,
          ),
          if (profileAsync.hasValue)
            _editing
                ? _saving
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                              onPressed: _cancelEdit,
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: _save, child: const Text('Save')),
                        ],
                      )
                : IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit profile',
                    onPressed: () {
                      final p = profileAsync.value!;
                      _startEdit(p.businessName, p.email, p.phone);
                    },
                  ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const ShimmerList(count: 5, itemHeight: 60),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (profile) {
          if (!_initialized) _initialized = true;
          return RefreshIndicator(
            onRefresh: () => notifier.refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profile.logoUrl != null
                      ? NetworkImage(profile.logoUrl!)
                      : null,
                  child: profile.logoUrl == null
                      ? Text(
                          profile.businessName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 28),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                if (!_editing)
                  Center(
                    child: Text(
                      profile.businessName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                const SizedBox(height: 24),

                // ── Edit mode ───────────────────────────────────────────────
                if (_editing) ...[
                  TextFormField(
                    controller: _nameCtrl,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    maxLength: 100,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) {
                      final changed = val.trim() != _originalEmail;
                      setState(() {
                        _emailChangedAndUnverified =
                            changed && !_emailVerifiedInSession;
                        if (!changed) _emailVerifiedInSession = false;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      suffixIcon: _emailChangedAndUnverified
                          ? TextButton(
                              onPressed: _verifyNewEmail,
                              child: const Text('Verify'),
                            )
                          : _emailVerifiedInSession
                              ? const Icon(Icons.verified_rounded,
                                  color: Colors.green, size: 18)
                              : null,
                      helperText: _emailChangedAndUnverified
                          ? 'Tap Verify to confirm new email'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneCtrl,
                    maxLength: 15,
                    keyboardType: TextInputType.phone,
                    onChanged: (val) {
                      final changed = val.trim() != _originalPhone;
                      setState(() {
                        _phoneChangedAndUnverified =
                            changed && !_phoneVerifiedInSession;
                        if (!changed) _phoneVerifiedInSession = false;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      suffixIcon: _phoneChangedAndUnverified
                          ? TextButton(
                              onPressed: _verifyNewPhone,
                              child: const Text('Verify'),
                            )
                          : _phoneVerifiedInSession
                              ? const Icon(Icons.verified_rounded,
                                  color: Colors.green, size: 18)
                              : null,
                      helperText: _phoneChangedAndUnverified
                          ? 'Tap Verify to confirm new phone'
                          : null,
                    ),
                  ),

                // ── View mode ───────────────────────────────────────────────
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(profile.email),
                    trailing: (profile.isEmailVerified || _emailVerified)
                        ? const Icon(Icons.verified_rounded,
                            color: Colors.green, size: 18)
                        : TextButton(
                            onPressed: () async {
                              final remote =
                                  ref.read(settingsRemoteSourceProvider);
                              final ok = await _showOtpDialog(
                                title: 'Verify Email',
                                description:
                                    'A 6-digit OTP will be sent to your email address.',
                                sendOtp: remote.sendEmailOtp,
                                confirmOtp: remote.confirmEmailOtp,
                              );
                              if (mounted) {
                                if (ok) setState(() => _emailVerified = true);
                                ref.invalidate(profileNotifierProvider);
                              }
                            },
                            child: const Text('Verify'),
                          ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('Phone'),
                    subtitle: Text(profile.phone),
                    trailing: (profile.isPhoneVerified || _phoneVerified)
                        ? const Icon(Icons.verified_rounded,
                            color: Colors.green, size: 18)
                        : TextButton(
                            onPressed: () async {
                              final remote =
                                  ref.read(settingsRemoteSourceProvider);
                              final ok = await _showOtpDialog(
                                title: 'Verify Phone',
                                description:
                                    'A 6-digit OTP will be sent to your phone number.',
                                sendOtp: remote.sendPhoneOtp,
                                confirmOtp: remote.confirmPhoneOtp,
                              );
                              if (mounted) {
                                if (ok) setState(() => _phoneVerified = true);
                                ref.invalidate(profileNotifierProvider);
                              }
                            },
                            child: const Text('Verify'),
                          ),
                  ),
                ],

                const Divider(height: 32),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  onTap: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) context.go(RouteNames.login);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
