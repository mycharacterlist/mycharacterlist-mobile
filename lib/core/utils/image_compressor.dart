import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class CompressedImageResult {
  const CompressedImageResult({
    required this.bytes,
    required this.extension,
  });

  final Uint8List bytes;
  final String extension;
}

/// Compresses uploaded images without lowering visible quality.
///
/// Uses the Dart [image] package to decode common formats (JPEG, PNG, WebP,
/// GIF, BMP, ...) and [flutter_image_compress] for native formats like HEIC.
/// Output is JPEG at quality 90 for regular photos, or PNG when transparency
/// is required. The original bytes are kept whenever nothing ends up smaller.
class ImageCompressor {
  const ImageCompressor();

  static const jpegQuality = 90;

  Future<CompressedImageResult> compress(
    Uint8List input, {
    String? sourcePath,
  }) async {
    final fallbackExtension = _extensionFromPath(sourcePath);
    final decoded = img.decodeImage(input);

    if (decoded == null) {
      return _preferSmaller(
        input,
        await _compressUndecodable(input, fallbackExtension),
        fallbackExtension,
      );
    }

    final candidates = <CompressedImageResult>[];

    if (!_hasTransparency(decoded)) {
      candidates.addAll(await _buildJpegCandidates(input, decoded));
    }

    final pngBytes = Uint8List.fromList(img.encodePng(decoded, level: 9));
    if (pngBytes.length < input.length) {
      candidates.add(CompressedImageResult(bytes: pngBytes, extension: '.png'));
    }

    if (candidates.isEmpty) {
      return CompressedImageResult(
        bytes: input,
        extension: fallbackExtension,
      );
    }

    candidates.sort(
      (left, right) => left.bytes.length.compareTo(right.bytes.length),
    );
    return _preferSmaller(input, candidates.first, fallbackExtension);
  }

  CompressedImageResult _preferSmaller(
    Uint8List input,
    CompressedImageResult candidate,
    String fallbackExtension,
  ) {
    if (candidate.bytes.length >= input.length) {
      return CompressedImageResult(
        bytes: input,
        extension: fallbackExtension,
      );
    }

    return candidate;
  }

  Future<List<CompressedImageResult>> _buildJpegCandidates(
    Uint8List input,
    img.Image decoded,
  ) async {
    final candidates = <CompressedImageResult>[];

    final nativeJpeg = await FlutterImageCompress.compressWithList(
      input,
      quality: jpegQuality,
      format: CompressFormat.jpeg,
    );
    if (nativeJpeg != null && nativeJpeg.length < input.length) {
      candidates.add(
        CompressedImageResult(bytes: nativeJpeg, extension: '.jpg'),
      );
    }

    final dartJpeg = Uint8List.fromList(
      img.encodeJpg(decoded, quality: jpegQuality),
    );
    if (dartJpeg.length < input.length) {
      candidates.add(CompressedImageResult(bytes: dartJpeg, extension: '.jpg'));
    }

    return candidates;
  }

  Future<CompressedImageResult> _compressUndecodable(
    Uint8List input,
    String fallbackExtension,
  ) async {
    final nativeJpeg = await FlutterImageCompress.compressWithList(
      input,
      quality: jpegQuality,
      format: CompressFormat.jpeg,
    );
    if (nativeJpeg != null && nativeJpeg.length < input.length) {
      return CompressedImageResult(bytes: nativeJpeg, extension: '.jpg');
    }

    final nativePng = await FlutterImageCompress.compressWithList(
      input,
      quality: jpegQuality,
      format: CompressFormat.png,
    );
    if (nativePng != null && nativePng.length < input.length) {
      return CompressedImageResult(bytes: nativePng, extension: '.png');
    }

    return CompressedImageResult(
      bytes: input,
      extension: fallbackExtension,
    );
  }

  bool _hasTransparency(img.Image image) {
    if (!image.hasAlpha) {
      return false;
    }

    for (var y = 0; y < image.height; y += 8) {
      for (var x = 0; x < image.width; x += 8) {
        if (image.getPixel(x, y).a < 255) {
          return true;
        }
      }
    }

    return false;
  }

  String _extensionFromPath(String? sourcePath) {
    if (sourcePath == null) {
      return '.jpg';
    }

    final extension = p.extension(sourcePath).toLowerCase();
    if (extension.isEmpty) {
      return '.jpg';
    }

    return extension;
  }
}
