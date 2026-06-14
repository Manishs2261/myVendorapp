import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_assets.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/cyber_glow_background.dart';
import '../../../../shared/widgets/glass_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final storage = ref.read(secureStorageProvider);
    final email = await storage.read('remember_email');
    final password = await storage.read('remember_password');
    final rememberMeStr = await storage.read('remember_me');
    if (rememberMeStr == 'true' && email != null && password != null) {
      if (mounted) {
        setState(() {
          _emailCtrl.text = email;
          _passCtrl.text = password;
          _rememberMe = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final storage = ref.read(secureStorageProvider);
    if (_rememberMe) {
      await storage.write(key: 'remember_email', value: _emailCtrl.text.trim());
      await storage.write(key: 'remember_password', value: _passCtrl.text);
      await storage.write(key: 'remember_me', value: 'true');
    } else {
      await storage.delete('remember_email');
      await storage.delete('remember_password');
      await storage.delete('remember_me');
    }

    await ref
        .read(authNotifierProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    ref.listen(authNotifierProvider, (_, next) {
      if (next.valueOrNull != null) context.go(RouteNames.dashboard);
      if (next.hasError) {
        final msg = next.error.toString();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(msg.isNotEmpty ? msg : 'Login failed. Please try again.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
      }
    });

    return CyberGlowBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo with premium glow
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        AppAssets.playstoreIcon,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // App name
                Text(
                  'My Shop',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'By Where is my shops.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Form glass card
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome back',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in to your account',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 28),
                        
                        // Email input
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.8)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.02),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.error),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email is required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Password input
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.8)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.02),
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePass = !_obscurePass),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.error),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppColors.primary,
                                    checkColor: Colors.black,
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (val) {
                                      setState(() => _rememberMe = val ?? false);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _rememberMe = !_rememberMe);
                                  },
                                  child: const Text(
                                    'Remember me',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => context.push(RouteNames.forgotPassword),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Glowing Sign In Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 16,
                                spreadRadius: -2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: authState.isLoading ? null : _submit,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryLight,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: authState.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: AppColors.textMuted.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Outlined/Glassmorphic Create Account Button
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => context.push(RouteNames.register),
                      child: const Center(
                        child: Text(
                          'Create an Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
