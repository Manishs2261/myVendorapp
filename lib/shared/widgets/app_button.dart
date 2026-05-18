import 'package:flutter/material.dart';

enum AppButtonVariant { primary, outlined, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final bool loading;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    return switch (variant) {
      AppButtonVariant.primary => FilledButton(
          onPressed: loading ? null : onTap,
          child: child,
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: loading ? null : onTap,
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: loading ? null : onTap,
          child: child,
        ),
    };
  }
}
