import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AiImageService {
  // Resize and compress before sending to AI — U2Net internally downsamples to
  // 320×320 for inference, so JPEG at quality 92 is visually identical to lossless
  // PNG from the AI's perspective while being ~10× smaller (150–400 KB vs 1–3 MB).
  Future<XFile> compressForUpload(XFile file) async {
    final bytes = await file.readAsBytes();
    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 1024,
      minHeight: 1024,
      quality: 92,
      format: CompressFormat.jpeg,
    );
    if (compressed.isEmpty || compressed.length >= bytes.length) return file;
    return _saveToTemp(
        compressed, '${p.basenameWithoutExtension(file.name)}_upload.jpg');
  }

  // Wrap raw bytes (e.g. PNG from backend) as a temp XFile.
  Future<XFile> bytesToXFile(Uint8List bytes, String filename) async {
    return _saveToTemp(bytes, filename);
  }

  // Final compression: WebP for opaque images, PNG preserved for transparent.
  Future<XFile> compressFinalImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final ext = p.extension(file.name).toLowerCase();

    // Keep PNG as-is if it may be transparent (background-removed result).
    if (ext == '.png') {
      return _saveToTemp(bytes, p.basename(file.name));
    }

    final compressed = await FlutterImageCompress.compressWithList(
      bytes,
      quality: 88,
      format: CompressFormat.webp,
    );
    if (compressed.length >= bytes.length) return file;
    final name = '${p.basenameWithoutExtension(file.name)}.webp';
    return _saveToTemp(compressed, name);
  }

  Future<XFile> _saveToTemp(Uint8List bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final filePath = p.join(dir.path, filename);
    await File(filePath).writeAsBytes(bytes, flush: true);
    return XFile(filePath, name: filename);
  }
}
