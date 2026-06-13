import 'dart:isolate';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/ai_image_remote_source.dart';
import '../../domain/ai_image_service.dart';

part 'ai_image_provider.g.dart';

class AiImageResult {
  final XFile originalFile;
  final XFile processedFile;
  const AiImageResult({required this.originalFile, required this.processedFile});
}

/// Tracks the current processing stage for display in the loading overlay.
final aiProgressProvider = StateProvider<String>((ref) => '');

@riverpod
AiImageRemoteSource aiImageRemoteSource(Ref ref) =>
    AiImageRemoteSource(ref.read(dioProvider));

@riverpod
AiImageService aiImageService(Ref ref) => AiImageService();

@riverpod
class AiImageNotifier extends _$AiImageNotifier {
  CancelToken? _cancelToken;

  @override
  FutureOr<AiImageResult?> build() {
    ref.onDispose(() => _cancelToken?.cancel('disposed'));
    return null;
  }

  void _setProgress(String msg) =>
      ref.read(aiProgressProvider.notifier).state = msg;

  Future<void> process(XFile original) async {
    // Cancel any in-flight request before starting a new one.
    _cancelToken?.cancel('superseded');
    _cancelToken = CancelToken();

    state = const AsyncLoading();
    _setProgress('Compressing image…');

    try {
      final service = ref.read(aiImageServiceProvider);
      final remote = ref.read(aiImageRemoteSourceProvider);

      // Compression uses a platform channel (native thread) — no isolate needed.
      final compressed = await service.compressForUpload(original);

      _setProgress('Sending to AI…');
      final rawBytes = await remote.removeBackground(
        compressed,
        cancelToken: _cancelToken,
      );

      // Convert List<int> → Uint8List off the main thread to avoid GC stall
      // on large PNG responses.
      _setProgress('Processing result…');
      final pngBytes = await Isolate.run(() => Uint8List.fromList(rawBytes));

      final baseName =
          '${original.name.replaceAll(RegExp(r'\.[^.]+$'), '')}_nobg.png';
      final processed = await service.bytesToXFile(pngBytes, baseName);

      _setProgress('');
      state = AsyncData(
          AiImageResult(originalFile: original, processedFile: processed));
    } catch (e, st) {
      _setProgress('');
      if (e is DioException && e.type == DioExceptionType.cancel) return;
      state = AsyncError(e, st);
    }
  }

  /// Cancel the in-flight request and reset to idle.
  void cancel() {
    _cancelToken?.cancel('user cancelled');
    _cancelToken = null;
    _setProgress('');
    state = const AsyncData(null);
  }

  Future<void> retry(XFile original) => process(original);

  void reset() {
    _cancelToken?.cancel('reset');
    _cancelToken = null;
    _setProgress('');
    state = const AsyncData(null);
  }

}
