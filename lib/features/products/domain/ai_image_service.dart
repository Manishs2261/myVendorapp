import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AiImageService {
  // Resize before sending to AI — U2Net doesn't need 4K.
  // PNG is lossless: zero quality degradation, only pixel dimensions are reduced.
  // Shorter side is capped at ~1024 px to keep PNG file size under the 10 MB limit.
  Future<XFile> compressForUpload(XFile file) async {
    final bytes = await file.readAsBytes();
    final resized = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 1024,
      minHeight: 1024,
      quality: 85, // for PNG: controls zlib compression speed, not visual quality
      format: CompressFormat.png,
    );
    if (resized.isEmpty || resized.length >= bytes.length) {
      return file;
    }
    return _saveToTemp(
        resized, '${p.basenameWithoutExtension(file.name)}_upload.png');
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
