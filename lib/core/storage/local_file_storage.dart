import 'dart:io';
import 'dart:typed_data';

import 'package:mycharacterlist/core/storage/compressed_images_manifest.dart';
import 'package:mycharacterlist/core/storage/storage_path_utils.dart';
import 'package:mycharacterlist/core/utils/image_compressor.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;

part 'local_file_storage_drafts.dart';
part 'local_file_storage_paths.dart';

class LocalFileStorage {
  LocalFileStorage({ImageCompressor? imageCompressor})
    : _imageCompressor = imageCompressor ?? const ImageCompressor() {
    _paths = _LocalFileStoragePaths(this);
    _drafts = _LocalFileStorageDrafts(this);
  }

  static const draftsFolder = '_drafts';
  static const storageFolderName = 'mycharacterlist_files';

  final ImageCompressor _imageCompressor;
  late final _LocalFileStoragePaths _paths;
  late final _LocalFileStorageDrafts _drafts;

  // ---------------------------------------------------------------------------
  // Paths
  // ---------------------------------------------------------------------------

  /// Resolves a stored image path to an existing file, including legacy folders.
  Future<String?> resolveExistingImagePath(
    String? path, {
    String? characterFolder,
  }) {
    return _paths.resolveExistingImagePath(
      path,
      characterFolder: characterFolder,
    );
  }

  // ---------------------------------------------------------------------------
  // Drafts
  // ---------------------------------------------------------------------------

  /// Compresses a picked image immediately and stores it in [draftsFolder].
  Future<String> compressAndStagePickedFile(String sourcePath) {
    return _drafts.compressAndStagePickedFile(sourcePath);
  }

  Future<void> deleteDraftFile(String? path) => _drafts.deleteDraftFile(path);

  Future<void> deleteDraftFiles(Iterable<String> paths) {
    return _drafts.deleteDraftFiles(paths);
  }

  /// Removes leftover files from [draftsFolder] after they were moved to a
  /// character folder or when the form is abandoned.
  Future<void> clearDraftsFolder() => _drafts.clearDraftsFolder();

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

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

    final resolvedExtension = StoragePathUtils.resolveExtension(
      preferredExtension: preferredExtension,
      fallbackExtension: extension,
    );
    final destinationPath = StoragePathUtils.uniqueFilePath(
      directoryPath: destinationDirectory.path,
      extension: resolvedExtension,
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

  Future<String> saveFile(
    String sourcePath, {
    required String folder,
    bool compress = true,
  }) async {
    final resolvedPath = await resolveExistingImagePath(
      sourcePath,
      characterFolder: folder,
    );
    if (resolvedPath == null) {
      throw StateError('File does not exist: $sourcePath');
    }

    final sourceFile = File(resolvedPath);
    final storageRoot = await _storageRoot();
    final normalizedSourcePath = StoragePathUtils.normalizePathForComparison(
      sourceFile.absolute.path,
    );
    final destinationDirectory = Directory(p.join(storageRoot.path, folder));
    await destinationDirectory.create(recursive: true);
    final normalizedDestinationPath = StoragePathUtils.normalizePathForComparison(
      destinationDirectory.absolute.path,
    );
    final normalizedStorageRoot = StoragePathUtils.normalizePathForComparison(
      storageRoot.path,
    );

    if (StoragePathUtils.isInsideDirectory(
      normalizedSourcePath,
      normalizedDestinationPath,
    )) {
      return sourceFile.absolute.path;
    }

    if (StoragePathUtils.isInsideDirectory(
      normalizedSourcePath,
      normalizedStorageRoot,
    )) {
      final relocatedPath = await _relocateStoredFile(
        sourceFile,
        destinationDirectory,
      );
      if (StoragePathUtils.isInsideDrafts(
        normalizedSourcePath,
        normalizedStorageRoot,
        draftsFolder,
      )) {
        await markImageAsCompressed(folder, relocatedPath);
      }
      return relocatedPath;
    }

    final bytes = await sourceFile.readAsBytes();
    if (!compress) {
      final destinationPath = StoragePathUtils.uniqueFilePath(
        directoryPath: destinationDirectory.path,
        extension: p.extension(sourceFile.path),
      );
      await File(destinationPath).writeAsBytes(bytes);
      return destinationPath;
    }

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
    final destinationPath = StoragePathUtils.uniqueFilePath(
      directoryPath: destinationDirectory.path,
      extension: outputExtension,
    );

    await File(destinationPath).writeAsBytes(outputBytes);
    if (outputBytes.length < bytes.length) {
      await markImageAsCompressed(folder, destinationPath);
    }
    return destinationPath;
  }

  // ---------------------------------------------------------------------------
  // Compression manifest
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> deleteFile(String? path, {String? characterFolder}) async {
    if (path == null || path.trim().isEmpty) {
      return;
    }

    final resolvedPath = await resolveExistingImagePath(
      path,
      characterFolder: characterFolder,
    );
    if (resolvedPath == null) {
      return;
    }

    final storageRoot = await _storageRoot();
    final file = File(resolvedPath);
    final normalizedPath = StoragePathUtils.normalizePathForComparison(
      file.absolute.path,
    );
    final normalizedStorageRoot = StoragePathUtils.normalizePathForComparison(
      storageRoot.path,
    );

    if (!StoragePathUtils.isInsideDirectory(
      normalizedPath,
      normalizedStorageRoot,
    )) {
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

  Future<void> deleteFolder(String folder) async {
    final storageRoot = await _storageRoot();
    final directory = Directory(p.join(storageRoot.path, folder));
    final normalizedPath = StoragePathUtils.normalizePathForComparison(
      directory.absolute.path,
    );
    final normalizedStorageRoot = StoragePathUtils.normalizePathForComparison(
      storageRoot.path,
    );

    if (!StoragePathUtils.isInsideDirectory(
      normalizedPath,
      normalizedStorageRoot,
    )) {
      return;
    }

    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Storage root
  // ---------------------------------------------------------------------------

  Future<Directory> storageRoot() => _storageRoot();

  // ---------------------------------------------------------------------------
  // Internal helpers (library-private, shared with part classes)
  // ---------------------------------------------------------------------------

  Future<String> _relocateStoredFile(
    File sourceFile,
    Directory destinationDirectory,
  ) async {
    final destinationPath = StoragePathUtils.uniqueFilePath(
      directoryPath: destinationDirectory.path,
      extension: p.extension(sourceFile.path),
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

  Future<Directory> _storageRoot() async {
    final documentsDirectory = await path_provider
        .getApplicationDocumentsDirectory();
    final storageRoot = Directory(
      p.join(documentsDirectory.path, storageFolderName),
    );

    await storageRoot.create(recursive: true);
    return storageRoot;
  }
}
