import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/router/route_names.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/cyber_glow_background.dart';
import '../../../../shared/widgets/glass_card.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authRemoteSourceProvider).forgotPassword(_emailCtrl.text.trim());
      if (!mounted) return;
      context.push(RouteNames.verifyCode, extra: _emailCtrl.text.trim());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CyberGlowBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 32, spreadRadius: 2)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(AppAssets.playstoreIcon, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('My Shop', textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Text('Reset your password', textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted, letterSpacing: 1.2)),
                const SizedBox(height: 32),
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Forgot Password', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text("Enter your email and we'll send you a 6-digit reset code.",
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textMuted, fontSize: 13)),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.8)),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.02),
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email is required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, spreadRadius: -2, offset: const Offset(0, 4))],
                          ),
                          child: InkWell(
                            onTap: _isLoading ? null : _submit,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                                    : const Text('Send Code', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                TextButton(
                  onPressed: () => context.pop(),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: RichText(
                    text: TextSpan(
                      text: 'Remember your password? ',
                      style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.8), fontSize: 13),
                      children: const [TextSpan(text: 'Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
