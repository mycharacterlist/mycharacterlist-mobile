import 'dart:io';

import 'package:mycharacterlist/core/storage/local_file_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract final class AppDiskCache {
  AppDiskCache._();

  static const _staleAfter = Duration(hours: 24);

  static Future<void> cleanUnused({bool includeDrafts = false}) async {
    await _cleanTemporaryDirectory();

    if (includeDrafts) {
      await LocalFileStorage().clearDraftsFolder();
    }
  }

  static Future<void> deleteFileIfTemporary(String? path) async {
    if (path == null || path.trim().isEmpty) {
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      return;
    }

    final tempDirectory = await getTemporaryDirectory();
    if (!_isInsideDirectory(file.absolute.path, tempDirectory.absolute.path)) {
      return;
    }

    await file.delete();
  }

  static Future<void> _cleanTemporaryDirectory() async {
    final tempDirectory = await getTemporaryDirectory();
    if (!await tempDirectory.exists()) {
      return;
    }

    final now = DateTime.now();

    await for (final entity in tempDirectory.list(followLinks: false)) {
      if (entity is! File) {
        continue;
      }

      final fileName = p.basename(entity.path);
      if (fileName.startsWith('import_') && fileName.endsWith('.json')) {
        await _deleteIfExists(entity);
        continue;
      }

      final modified = (await entity.stat()).modified;
      if (now.difference(modified) >= _staleAfter) {
        await _deleteIfExists(entity);
      }
    }
  }

  static Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  static bool _isInsideDirectory(String path, String directoryPath) {
    final normalizedDirectoryPath = directoryPath.endsWith(Platform.pathSeparator)
        ? directoryPath
        : '$directoryPath${Platform.pathSeparator}';

    return path == directoryPath || path.startsWith(normalizedDirectoryPath);
  }
}
