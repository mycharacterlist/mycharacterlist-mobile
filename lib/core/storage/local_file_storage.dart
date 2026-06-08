import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;

class LocalFileStorage {
  Future<String?> saveOptionalFile(
    String? sourcePath, {
    required String folder,
  }) async {
    if (sourcePath == null || sourcePath.trim().isEmpty) {
      return null;
    }

    return saveFile(sourcePath, folder: folder);
  }

  Future<List<String>> saveFiles(
    List<String> sourcePaths, {
    required String folder,
  }) async {
    final savedPaths = <String>[];

    for (final sourcePath in sourcePaths) {
      if (sourcePath.trim().isEmpty) {
        continue;
      }

      savedPaths.add(await saveFile(sourcePath, folder: folder));
    }

    return savedPaths;
  }

  Future<String> saveFile(String sourcePath, {required String folder}) async {
    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw StateError('File does not exist: $sourcePath');
    }

    final storageRoot = await _storageRoot();
    final normalizedSourcePath = sourceFile.absolute.path;

    if (_isInsideDirectory(normalizedSourcePath, storageRoot.path)) {
      return normalizedSourcePath;
    }

    final destinationDirectory = Directory(p.join(storageRoot.path, folder));
    await destinationDirectory.create(recursive: true);

    final destinationPath = p.join(
      destinationDirectory.path,
      _createFileName(sourceFile.path),
    );

    final savedFile = await sourceFile.copy(destinationPath);
    return savedFile.path;
  }

  Future<void> deleteFile(String? path) async {
    if (path == null || path.trim().isEmpty) {
      return;
    }

    final storageRoot = await _storageRoot();
    final file = File(path);
    final normalizedPath = file.absolute.path;

    if (!_isInsideDirectory(normalizedPath, storageRoot.path)) {
      return;
    }

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteFiles(List<String> paths) async {
    for (final path in paths) {
      await deleteFile(path);
    }
  }

  Future<void> deleteFolder(String folder) async {
    final storageRoot = await _storageRoot();
    final directory = Directory(p.join(storageRoot.path, folder));
    final normalizedPath = directory.absolute.path;

    if (!_isInsideDirectory(normalizedPath, storageRoot.path)) {
      return;
    }

    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<Directory> _storageRoot() async {
    final documentsDirectory = await path_provider
        .getApplicationDocumentsDirectory();
    final storageRoot = Directory(
      p.join(documentsDirectory.path, 'mycharacterlist_files'),
    );

    await storageRoot.create(recursive: true);
    return storageRoot;
  }

  bool _isInsideDirectory(String path, String directoryPath) {
    final normalizedDirectoryPath =
        directoryPath.endsWith(Platform.pathSeparator)
        ? directoryPath
        : '$directoryPath${Platform.pathSeparator}';

    return path == directoryPath || path.startsWith(normalizedDirectoryPath);
  }

  String _createFileName(String sourcePath) {
    final extension = _extensionOf(sourcePath);
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    return extension.isEmpty ? '$timestamp' : '$timestamp$extension';
  }

  String _extensionOf(String path) {
    final fileName = p.basename(path);
    final dotIndex = fileName.lastIndexOf('.');

    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }

    return fileName.substring(dotIndex);
  }
}
