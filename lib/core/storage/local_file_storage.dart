import 'dart:io';
import 'dart:typed_data';

import 'package:mycharacterlist/core/storage/compressed_images_manifest.dart';
import 'package:mycharacterlist/core/utils/image_compressor.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;

class LocalFileStorage {
  LocalFileStorage({ImageCompressor? imageCompressor})
    : _imageCompressor = imageCompressor ?? const ImageCompressor();

  static const draftsFolder = '_drafts';

  final ImageCompressor _imageCompressor;

  Future<String> saveBytes(
    Uint8List bytes, {
    required String folder,
    String extension = '',
    bool compress = true,
  }) async {
    final storageRoot = await _storageRoot();
    final destinationDirectory = Directory(p.join(storageRoot.path, folder));
    await destinationDirectory.create(recursive: true);

    final Uint8List outputBytes;
    final String preferredExtension;
    if (compress) {
      final compressed = await _imageCompressor.compress(bytes);
      if (compressed.bytes.length < bytes.length) {
        outputBytes = compressed.bytes;
        preferredExtension = compressed.extension;
      } else {
        outputBytes = bytes;
        preferredExtension = extension;
      }
    } else {
      outputBytes = bytes;
      preferredExtension = extension;
    }

    final resolvedExtension = _resolveExtension(
      preferredExtension: preferredExtension,
      fallbackExtension: extension,
    );
    final destinationPath = p.join(
      destinationDirectory.path,
      '${DateTime.now().microsecondsSinceEpoch}$resolvedExtension',
    );

    return (await File(destinationPath).writeAsBytes(outputBytes)).path;
  }

  /// Saves imported image bytes. Skips compression when [alreadyCompressed] is
  /// true and updates the character manifest accordingly.
  Future<String> saveImportedImageBytes(
    Uint8List bytes, {
    required String folder,
    String? sourcePath,
    String extension = '',
    bool alreadyCompressed = false,
  }) async {
    if (alreadyCompressed) {
      final savedPath = await saveBytes(
        bytes,
        folder: folder,
        extension: extension,
        compress: false,
      );
      await markImageAsCompressed(folder, savedPath);
      return savedPath;
    }

    final compressed = await _imageCompressor.compress(
      bytes,
      sourcePath: sourcePath,
    );
    final wasCompressed = compressed.bytes.length < bytes.length;
    final savedPath = await saveBytes(
      compressed.bytes,
      folder: folder,
      extension: compressed.extension.isNotEmpty
          ? compressed.extension
          : extension,
      compress: false,
    );

    if (wasCompressed) {
      await markImageAsCompressed(folder, savedPath);
    }

    return savedPath;
  }

  Future<Set<String>> getCompressedImageNames(String characterFolder) async {
    final directory = await _characterDirectory(characterFolder);
    return CompressedImagesManifest.read(directory);
  }

  Future<bool> isImageCompressed(
    String characterFolder,
    String? imagePath,
  ) async {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return false;
    }

    final directory = await _characterDirectory(characterFolder);
    return CompressedImagesManifest.contains(
      directory,
      p.basename(imagePath),
    );
  }

  Future<void> markImageAsCompressed(
    String characterFolder,
    String imagePath,
  ) async {
    final directory = await _characterDirectory(characterFolder);
    await CompressedImagesManifest.mark(directory, imagePath);
  }

  Future<void> unmarkImageAsCompressed(
    String characterFolder,
    String imagePath,
  ) async {
    final directory = await _characterDirectory(characterFolder);
    await CompressedImagesManifest.unmark(directory, imagePath);
  }

  Future<void> syncCompressedManifest(
    String characterFolder,
    Iterable<String> imagePaths,
  ) async {
    final directory = await _characterDirectory(characterFolder);
    await CompressedImagesManifest.syncWithImages(directory, imagePaths);
  }

  /// Marks every image path as processed after one-time migration.
  Future<void> markMigrationProcessedImages(
    String characterFolder,
    Iterable<String> imagePaths,
  ) async {
    final directory = await _characterDirectory(characterFolder);
    final compressedFiles = imagePaths
        .where((path) => path.trim().isNotEmpty)
        .map((path) => p.basename(path))
        .toSet();

    await CompressedImagesManifest.write(directory, compressedFiles);
  }

  /// Marks images processed during one-time migration. Files that are already
  /// as small as the compressor can make them are treated as compressed too.
  Future<void> markMigratedImagesAsCompressed(
    String characterFolder,
    Iterable<String> imagePaths,
  ) async {
    for (final path in imagePaths) {
      if (path.trim().isEmpty) {
        continue;
      }

      final file = File(path);
      if (!await file.exists()) {
        continue;
      }

      final bytes = await file.readAsBytes();
      final compressed = await _imageCompressor.compress(
        bytes,
        sourcePath: file.path,
      );

      if (compressed.bytes.length < bytes.length) {
        await markImageAsCompressed(characterFolder, path);
      }
    }

    await syncCompressedManifest(characterFolder, imagePaths);
  }

  Future<File?> compressedManifestFile(String characterFolder) async {
    final directory = await _characterDirectory(characterFolder);
    final manifestFile = File(
      p.join(directory.path, CompressedImagesManifest.fileName),
    );
    if (!await manifestFile.exists()) {
      return null;
    }

    return manifestFile;
  }

  /// Compresses a picked image immediately and stores it in [draftsFolder].
  Future<String> compressAndStagePickedFile(String sourcePath) async {
    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw StateError('File does not exist: $sourcePath');
    }

    final bytes = await sourceFile.readAsBytes();
    final compressed = await _imageCompressor.compress(
      bytes,
      sourcePath: sourceFile.path,
    );

    if (compressed.bytes.length >= bytes.length) {
      return saveBytes(
        bytes,
        folder: draftsFolder,
        extension: p.extension(sourceFile.path),
        compress: false,
      );
    }

    return saveBytes(
      compressed.bytes,
      folder: draftsFolder,
      extension: compressed.extension,
      compress: false,
    );
  }

  Future<void> deleteDraftFile(String? path) async {
    if (path == null || path.trim().isEmpty) {
      return;
    }

    final storageRoot = await _storageRoot();
    final draftsDirectory = Directory(p.join(storageRoot.path, draftsFolder));
    final file = File(path);
    final normalizedPath = file.absolute.path;

    if (!_isInsideDirectory(normalizedPath, draftsDirectory.absolute.path)) {
      return;
    }

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteDraftFiles(Iterable<String> paths) async {
    for (final path in paths) {
      await deleteDraftFile(path);
    }
  }

  /// Removes leftover files from [draftsFolder] after they were moved to a
  /// character folder or when the form is abandoned.
  Future<void> clearDraftsFolder() async {
    final storageRoot = await _storageRoot();
    final draftsDirectory = Directory(p.join(storageRoot.path, draftsFolder));

    if (!await draftsDirectory.exists()) {
      return;
    }

    await for (final entity in draftsDirectory.list()) {
      if (entity is File) {
        await entity.delete();
      }
    }
  }

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
    final destinationDirectory = Directory(p.join(storageRoot.path, folder));
    await destinationDirectory.create(recursive: true);
    final normalizedDestinationPath = destinationDirectory.absolute.path;

    if (_isInsideDirectory(normalizedSourcePath, normalizedDestinationPath)) {
      return normalizedSourcePath;
    }

    if (_isInsideDirectory(normalizedSourcePath, storageRoot.path)) {
      final relocatedPath = await _relocateStoredFile(
        sourceFile,
        destinationDirectory,
      );
      if (_isInsideDrafts(normalizedSourcePath, storageRoot.path)) {
        await markImageAsCompressed(folder, relocatedPath);
      }
      return relocatedPath;
    }

    final bytes = await sourceFile.readAsBytes();
    final compressed = await _imageCompressor.compress(
      bytes,
      sourcePath: sourceFile.path,
    );
    final outputBytes = compressed.bytes.length < bytes.length
        ? compressed.bytes
        : bytes;
    final outputExtension = compressed.bytes.length < bytes.length
        ? compressed.extension
        : p.extension(sourceFile.path);
    final destinationPath = p.join(
      destinationDirectory.path,
      '${DateTime.now().microsecondsSinceEpoch}$outputExtension',
    );

    await File(destinationPath).writeAsBytes(outputBytes);
    if (outputBytes.length < bytes.length) {
      await markImageAsCompressed(folder, destinationPath);
    }
    return destinationPath;
  }

  Future<void> deleteFile(String? path, {String? characterFolder}) async {
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
      if (characterFolder != null) {
        await unmarkImageAsCompressed(characterFolder, normalizedPath);
      }
    }
  }

  Future<void> deleteFiles(
    List<String> paths, {
    String? characterFolder,
  }) async {
    for (final path in paths) {
      await deleteFile(path, characterFolder: characterFolder);
    }
  }

  /// Compresses a file already stored in app storage when a smaller result is
  /// possible. Returns the path to use (unchanged when already optimal).
  Future<String?> compressStoredFileIfNeeded(String? path) async {
    if (path == null || path.trim().isEmpty) {
      return path;
    }

    final file = File(path);
    if (!await file.exists()) {
      return path;
    }

    final storageRoot = await _storageRoot();
    final normalizedPath = file.absolute.path;
    if (!_isInsideDirectory(normalizedPath, storageRoot.path)) {
      return path;
    }

    final originalBytes = await file.readAsBytes();
    final compressed = await _imageCompressor.compress(
      originalBytes,
      sourcePath: file.path,
    );

    if (compressed.bytes.length >= originalBytes.length) {
      return path;
    }

    final characterFolder = p.basename(file.parent.path);
    final destinationPath = p.join(
      file.parent.path,
      '${DateTime.now().microsecondsSinceEpoch}${compressed.extension}',
    );
    await File(destinationPath).writeAsBytes(compressed.bytes);
    await file.delete();
    await unmarkImageAsCompressed(characterFolder, normalizedPath);
    await markImageAsCompressed(characterFolder, destinationPath);
    return destinationPath;
  }

  Future<Directory> storageRoot() => _storageRoot();

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

  Future<String> _relocateStoredFile(
    File sourceFile,
    Directory destinationDirectory,
  ) async {
    final destinationPath = p.join(
      destinationDirectory.path,
      '${DateTime.now().microsecondsSinceEpoch}${p.extension(sourceFile.path)}',
    );

    try {
      return (await sourceFile.rename(destinationPath)).path;
    } on FileSystemException {
      await sourceFile.copy(destinationPath);
      await sourceFile.delete();
      return destinationPath;
    }
  }

  Future<Directory> _characterDirectory(String characterFolder) async {
    final storageRoot = await _storageRoot();
    final directory = Directory(p.join(storageRoot.path, characterFolder));
    await directory.create(recursive: true);
    return directory;
  }

  bool _isInsideDrafts(String path, String storageRootPath) {
    final draftsDirectory = p.join(storageRootPath, draftsFolder);
    return _isInsideDirectory(path, draftsDirectory);
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

  String _resolveExtension({
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
}
