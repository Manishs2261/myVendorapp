import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/cyber_glow_background.dart';
import '../../../../shared/widgets/glass_card.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());
  
  bool _isLoading = false;
  int _timerSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timerSeconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timerSeconds == 0) {
        setState(() => _timer?.cancel());
      } else {
        setState(() => _timerSeconds--);
      }
    });
  }

  String _maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return 'your email';
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) {
      return '${name[0]}***@$domain';
    }
    return '${name.substring(0, 2)}***${name.substring(name.length - 1)}@$domain';
  }

  void _submit() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the 5-digit verification code.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate OTP verification API call
    Future.delayed(const Duration(seconds: 15.0 ~/ 10.0), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.push(RouteNames.newPassword, extra: widget.email);
    });
  }

  void _resendCode() {
    if (_timerSeconds > 0) return;
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Verification code resent successfully.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
                // Premium Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Logo with glow
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 32,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        AppAssets.playstoreIcon,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                  'Reset your password',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Glass Card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Verify Code',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enter the 5-digit code we sent to your email.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 28),
                      
                      // 5-digit PIN custom layout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) {
                          return SizedBox(
                            width: 52,
                            height: 58,
                            child: TextFormField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                                fillColor: Colors.white.withOpacity(0.02),
                                filled: true,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  if (index < 4) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else {
                                    _focusNodes[index].unfocus();
                                  }
                                } else {
                                  if (index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      
                      // Code sent indicator
                      Center(
                        child: Text(
                          'Code sent to ${_maskEmail(widget.email)}',
                          style: TextStyle(
                            color: AppColors.textMuted.withOpacity(0.8),
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      
                      // Glowing Gradient Button
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
                          onTap: _isLoading ? null : _submit,
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
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                      ),
                                    )
                                  : const Text(
                                      'Verify',
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
                      const SizedBox(height: 20),
                      
                      // Resend code timer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Didn\'t get the code? ',
                            style: TextStyle(
                              color: AppColors.textMuted.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                          InkWell(
                            onTap: _timerSeconds == 0 ? _resendCode : null,
                            child: Text(
                              _timerSeconds > 0
                                  ? 'Resend in ${_timerSeconds}s'
                                  : 'Resend',
                              style: TextStyle(
                                color: _timerSeconds > 0
                                    ? AppColors.textMuted.withOpacity(0.5)
                                    : AppColors.primary,
                                fontSize: 13,
                                fontWeight: _timerSeconds > 0
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                                decoration: _timerSeconds == 0
                                    ? TextDecoration.underline
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
