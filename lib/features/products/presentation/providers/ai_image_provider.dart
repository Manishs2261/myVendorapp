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

@riverpod
AiImageRemoteSource aiImageRemoteSource(Ref ref) =>
    AiImageRemoteSource(ref.read(dioProvider));

@riverpod
AiImageService aiImageService(Ref ref) => AiImageService();

@riverpod
class AiImageNotifier extends _$AiImageNotifier {
  @override
  FutureOr<AiImageResult?> build() => null;

  Future<void> process(XFile original) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(aiImageServiceProvider);
      final remote = ref.read(aiImageRemoteSourceProvider);

      final compressed = await service.compressForUpload(original);
      final pngBytes = await remote.removeBackground(compressed);

      final baseName =
          '${original.name.replaceAll(RegExp(r'\.[^.]+$'), '')}_nobg.png';
      final processed = await service.bytesToXFile(pngBytes, baseName);

      state = AsyncData(
          AiImageResult(originalFile: original, processedFile: processed));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> retry(XFile original) => process(original);

  void reset() => state = const AsyncData(null);
}
