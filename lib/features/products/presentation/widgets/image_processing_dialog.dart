import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum ImageProcessingChoice { removeBackground, crop, skip }

class ImageProcessingDialog extends StatelessWidget {
  const ImageProcessingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Process Image',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How would you like to process this image?',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          _OptionTile(
            icon: Icons.auto_fix_high_rounded,
            iconColor: scheme.primary,
            title: 'Remove Background',
            subtitle: 'AI-powered · ~5 seconds',
            onTap: () => Navigator.pop(
                context, ImageProcessingChoice.removeBackground),
          ),
          const SizedBox(height: 8),
          _OptionTile(
            icon: Icons.crop_rounded,
            iconColor: Colors.orange,
            title: 'Crop & Edit',
            subtitle: 'Adjust framing, rotate',
            onTap: () =>
                Navigator.pop(context, ImageProcessingChoice.crop),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, ImageProcessingChoice.skip),
          child: const Text('Skip'),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(subtitle,
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
