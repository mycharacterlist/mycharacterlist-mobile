import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Tracks which image files in a character folder are already compressed.
///
/// Stored as `.compressed_images.json` next to the image files. The export
/// package copies this file into `images/<characterId>/`.
class CompressedImagesManifest {
  CompressedImagesManifest._();

  static const fileName = '.compressed_images.json';

  static Future<Set<String>> read(Directory characterDirectory) async {
    final manifestFile = File(p.join(characterDirectory.path, fileName));
    return readFromFile(manifestFile);
  }

  static Future<Set<String>> readFromFile(File manifestFile) async {
    if (!await manifestFile.exists()) {
      return {};
    }

    try {
      final decoded = jsonDecode(await manifestFile.readAsString());
      if (decoded is! Map) {
        return {};
      }

      final rawFiles = decoded['compressedFiles'];
      if (rawFiles is! List) {
        return {};
      }

      return rawFiles.map((file) => file.toString()).toSet();
    } on Object {
      return {};
    }
  }

  static Future<void> write(
    Directory characterDirectory,
    Set<String> compressedFiles,
  ) async {
    await characterDirectory.create(recursive: true);

    final manifestFile = File(p.join(characterDirectory.path, fileName));
    if (compressedFiles.isEmpty) {
      if (await manifestFile.exists()) {
        await manifestFile.delete();
      }
      return;
    }

    final sortedFiles = compressedFiles.toList()..sort();
    await manifestFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'compressedFiles': sortedFiles,
      }),
    );
  }

  static Future<void> mark(
    Directory characterDirectory,
    String imagePath,
  ) async {
    final files = await read(characterDirectory);
    files.add(p.basename(imagePath));
    await write(characterDirectory, files);
  }

  static Future<void> unmark(
    Directory characterDirectory,
    String imagePath,
  ) async {
    final files = await read(characterDirectory);
    files.remove(p.basename(imagePath));
    await write(characterDirectory, files);
  }

  static Future<bool> contains(
    Directory characterDirectory,
    String fileName,
  ) async {
    final files = await read(characterDirectory);
    return files.contains(fileName);
  }

  static Future<void> syncWithImages(
    Directory characterDirectory,
    Iterable<String> imagePaths,
  ) async {
    final existing = await read(characterDirectory);
    final currentNames = imagePaths.map(p.basename).toSet();
    existing.removeWhere((name) => !currentNames.contains(name));
    await write(characterDirectory, existing);
  }
}
