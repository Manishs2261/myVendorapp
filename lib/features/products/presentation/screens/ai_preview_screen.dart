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
  XFile? _recropped;
  bool _showSlider = true;

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
    final progress = ref.watch(aiProgressProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) ref.read(aiImageNotifierProvider.notifier).cancel();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          title: const Text('AI Background Removal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Cancel',
            onPressed: () {
              ref.read(aiImageNotifierProvider.notifier).cancel();
              Navigator.pop(context);
            },
          ),
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
          loading: () => _PremiumScannerLoading(
            originalFile: widget.initialFile,
            stage: progress,
            onCancel: () {
              ref.read(aiImageNotifierProvider.notifier).cancel();
              Navigator.pop(context);
            },
          ),
          error: (err, _) => _ErrorView(
            message: err.toString(),
            onRetry: _retry,
          ),
          data: (result) {
            if (result == null) {
              return _PremiumScannerLoading(
                originalFile: widget.initialFile,
                stage: progress,
                onCancel: () {
                  ref.read(aiImageNotifierProvider.notifier).cancel();
                  Navigator.pop(context);
                },
              );
            }
            final displayProcessed = _recropped ?? result.processedFile;

            return Column(
              children: [
                // View mode toggle bar
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface3,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showSlider = true),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _showSlider ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Compare Slider',
                                style: TextStyle(
                                  color: _showSlider ? Colors.black : AppColors.textMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showSlider = false),
                            child: Container(
                              decoration: BoxDecoration(
                                color: !_showSlider ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Side by Side',
                                style: TextStyle(
                                  color: !_showSlider ? Colors.black : AppColors.textMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _showSlider
                      ? BeforeAfterSlider(
                          originalFile: result.originalFile,
                          processedFile: displayProcessed,
                        )
                      : Row(
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _PremiumScannerLoading extends StatefulWidget {
  final XFile originalFile;
  final String stage;
  final VoidCallback onCancel;

  const _PremiumScannerLoading({
    required this.originalFile,
    required this.stage,
    required this.onCancel,
  });

  @override
  State<_PremiumScannerLoading> createState() => _PremiumScannerLoadingState();
}

class _PremiumScannerLoadingState extends State<_PremiumScannerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 0.5,
                        child: Image.file(
                          File(widget.originalFile.path),
                          fit: BoxFit.contain,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _animCtrl,
                        builder: (context, child) {
                          return Positioned.fill(
                            child: CustomPaint(
                              painter: _ScanLinePainter(_animCtrl.value),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Removing background…',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.stage.isNotEmpty ? widget.stage : 'AI is processing your image',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: widget.onCancel,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel Processing', style: TextStyle(color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double progress;
  _ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.0),
          AppColors.primary.withOpacity(0.4),
          AppColors.primary.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTRB(0, y - 24, size.width, y + 24));

    canvas.drawRect(Rect.fromLTRB(0, y - 24, size.width, y + 24), paint);

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
  }

  @override
  bool shouldRepaint(_ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
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

class BeforeAfterSlider extends StatefulWidget {
  final XFile originalFile;
  final XFile processedFile;

  const BeforeAfterSlider({
    super.key,
    required this.originalFile,
    required this.processedFile,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _sliderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final beforeWidget = Center(
          child: Image.file(
            File(widget.originalFile.path),
            fit: BoxFit.contain,
          ),
        );

        final afterWidget = Center(
          child: CheckerboardBackground(
            child: Image.file(
              File(widget.processedFile.path),
              fit: BoxFit.contain,
            ),
          ),
        );

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _sliderValue = (_sliderValue + details.delta.dx / width).clamp(0.0, 1.0);
            });
          },
          child: Stack(
            children: [
              Positioned.fill(child: afterWidget),
              Positioned.fill(
                child: ClipRect(
                  clipper: _SliderClipper(_sliderValue),
                  child: beforeWidget,
                ),
              ),
              Positioned(
                left: width * _sliderValue - 1.5,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  color: AppColors.primary,
                ),
              ),
              Positioned(
                left: width * _sliderValue - 20,
                top: height / 2 - 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 6, spreadRadius: 1, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.compare_arrows, color: Colors.black, size: 24),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Original', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Processed', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliderClipper extends CustomClipper<Rect> {
  final double sliderValue;
  _SliderClipper(this.sliderValue);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * sliderValue, size.height);
  }

  @override
  bool shouldReclip(_SliderClipper oldClipper) {
    return oldClipper.sliderValue != sliderValue;
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
