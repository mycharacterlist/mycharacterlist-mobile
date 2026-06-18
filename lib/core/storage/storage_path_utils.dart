import 'dart:io';

import 'package:path/path.dart' as p;

/// Pure path helpers shared by [LocalFileStorage].
abstract final class StoragePathUtils {
  StoragePathUtils._();

  static const imageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.gif',
    '.heic',
  };

  static String sanitizeStoredPath(String path) {
    var sanitized = path.trim();

    if (sanitized.startsWith('file://')) {
      sanitized = sanitized.substring('file://'.length);
    }

    try {
      sanitized = Uri.decodeComponent(sanitized);
    } on Object {
      // Keep the original path when URI decoding fails.
    }

    return p.normalize(sanitized);
  }

  static String normalizePathForComparison(String path) {
    var normalized = sanitizeStoredPath(path);

    if (Platform.isIOS || Platform.isMacOS) {
      if (normalized.startsWith('/var/') &&
          !normalized.startsWith('/private/')) {
        normalized = '/private$normalized';
      }
    }

    return normalized;
  }

  static bool isInsideDirectory(String path, String directoryPath) {
    final normalizedPath = normalizePathForComparison(path);
    final normalizedDirectory = normalizePathForComparison(directoryPath);
    final directoryPrefix = normalizedDirectory.endsWith('/')
        ? normalizedDirectory
        : '$normalizedDirectory/';

    return normalizedPath == normalizedDirectory ||
        normalizedPath.startsWith(directoryPrefix);
  }

  static bool isInsideDrafts(
    String path,
    String storageRootPath,
    String draftsFolder,
  ) {
    return isInsideDirectory(path, p.join(storageRootPath, draftsFolder));
  }

  static Iterable<String> iosPathVariants(String path) sync* {
    final normalized = p.normalize(path);
    yield normalized;

    if (Platform.isIOS || Platform.isMacOS) {
      if (normalized.startsWith('/var/') &&
          !normalized.startsWith('/private/')) {
        yield '/private$normalized';
      }
      if (normalized.startsWith('/private/var/')) {
        yield normalized.substring('/private'.length);
      }
    }
  }

  static String basenameKey(String path) {
    return p.basename(sanitizeStoredPath(path)).toLowerCase();
  }

  static bool isImageFileName(String fileName) {
    if (fileName.startsWith('.')) {
      return false;
    }

    return imageExtensions.contains(p.extension(fileName).toLowerCase());
  }

  static String resolveExtension({
    required String preferredExtension,
    required String fallbackExtension,
  }) {
    if (RegExp(r'^\.[a-zA-Z0-9]+$').hasMatch(preferredExtension)) {
      return preferredExtension;
    }

    if (RegExp(r'^\.[a-zA-Z0-9]+$').hasMatch(fallbackExtension)) {
      return fallbackExtension;
    }

    return '';
  }

  static String uniqueFilePath({
    required String directoryPath,
    required String extension,
  }) {
    return p.join(
      directoryPath,
      '${DateTime.now().microsecondsSinceEpoch}$extension',
    );
  }
}
