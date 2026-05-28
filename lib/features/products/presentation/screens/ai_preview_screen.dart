import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/ai_image_provider.dart';
import '../widgets/checkerboard_bg.dart';

class AiPreviewScreen extends ConsumerStatefulWidget {
  final XFile initialFile;
  const AiPreviewScreen({super.key, required this.initialFile});

  @override
  ConsumerState<AiPreviewScreen> createState() => _AiPreviewScreenState();
}

class _AiPreviewScreenState extends ConsumerState<AiPreviewScreen> {
  // Holds the processed file after optional re-crop; starts as null until AI done.
  XFile? _recropped;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiImageNotifierProvider.notifier).process(widget.initialFile);
    });
  }

  Future<void> _retry() =>
      ref.read(aiImageNotifierProvider.notifier).process(widget.initialFile);

  Future<void> _recrop(XFile processedFile) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: processedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Re-crop',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
        IOSUiSettings(
          title: 'Re-crop',
          aspectRatioLockEnabled: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
      ],
    );
    if (cropped != null && mounted) {
      setState(() => _recropped =
          XFile(cropped.path, name: cropped.path.split('/').last));
    }
  }

  void _confirm(XFile processedFile) {
    Navigator.pop(context, _recropped ?? processedFile);
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiImageNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        title: const Text('AI Background Removal',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          if (aiState.hasValue && aiState.value != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Retry',
              onPressed: _retry,
            ),
        ],
      ),
      body: aiState.when(
        loading: () => _LoadingOverlay(),
        error: (err, _) => _ErrorView(
          message: err.toString(),
          onRetry: _retry,
        ),
        data: (result) {
          if (result == null) return _LoadingOverlay();
          final displayProcessed = _recropped ?? result.processedFile;
          return Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _ImagePane(
                        label: 'Original',
                        file: result.originalFile,
                        isTransparent: false,
                      ),
                    ),
                    Container(width: 1, color: AppColors.border),
                    Expanded(
                      child: _ImagePane(
                        label: 'Processed',
                        file: displayProcessed,
                        isTransparent: true,
                      ),
                    ),
                  ],
                ),
              ),
              _BottomBar(
                onRecrop: () => _recrop(result.processedFile),
                onConfirm: () => _confirm(result.processedFile),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Removing background…',
              style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
          const SizedBox(height: 6),
          const Text('AI is processing your image',
              style: TextStyle(color: AppColors.textDim, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isModelLoading = message.contains('warming up') ||
        message.contains('model_loading') ||
        message.contains('503');

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isModelLoading
                  ? Icons.hourglass_top_rounded
                  : Icons.error_outline_rounded,
              size: 48,
              color: isModelLoading ? AppColors.warning : AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              isModelLoading
                  ? 'AI model is warming up'
                  : 'Background removal failed',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isModelLoading
                  ? 'The AI model is loading on the server. Please retry in ~30 seconds.'
                  : message,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePane extends StatelessWidget {
  final String label;
  final XFile file;
  final bool isTransparent;

  const _ImagePane({
    required this.label,
    required this.file,
    required this.isTransparent,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = PhotoView(
      imageProvider: FileImage(File(file.path)),
      backgroundDecoration: const BoxDecoration(color: Colors.transparent),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3,
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: AppColors.surface2,
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5),
          ),
        ),
        Expanded(
          child: isTransparent
              ? CheckerboardBackground(child: imageWidget)
              : imageWidget,
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onRecrop;
  final VoidCallback onConfirm;

  const _BottomBar({required this.onRecrop, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onRecrop,
              icon: const Icon(Icons.crop_rounded, size: 18),
              label: const Text('Re-crop'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Use This Image'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
