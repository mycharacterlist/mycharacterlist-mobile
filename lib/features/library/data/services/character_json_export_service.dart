import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:mycharacterlist/core/storage/compressed_images_manifest.dart';
import 'package:mycharacterlist/core/storage/local_file_storage.dart';
import 'package:mycharacterlist/features/characters/data/models/character_fact_model.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_repository.dart';
import 'package:mycharacterlist/features/library/domain/entities/character_export_result.dart';
import 'package:mycharacterlist/features/library/domain/entities/character_import_progress.dart';
import 'package:mycharacterlist/features/patches/data/models/ranking_list_patch_entry_model.dart';
import 'package:mycharacterlist/features/patches/data/models/ranking_list_patch_model.dart';
import 'package:mycharacterlist/features/patches/domain/entities/ranking_list_patch.dart';
import 'package:mycharacterlist/features/patches/domain/repositories/patch_repository.dart';
import 'package:mycharacterlist/features/ranking_lists/data/models/ranking_list_model.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/repositories/ranking_list_repository.dart';

class CharacterJsonExportService {
  const CharacterJsonExportService({
    required CharacterRepository characterRepository,
    required RankingListRepository rankingListRepository,
    required PatchRepository patchRepository,
    required LocalFileStorage localFileStorage,
  }) : _characterRepository = characterRepository,
       _rankingListRepository = rankingListRepository,
       _patchRepository = patchRepository,
       _localFileStorage = localFileStorage;

  final CharacterRepository _characterRepository;
  final RankingListRepository _rankingListRepository;
  final PatchRepository _patchRepository;
  final LocalFileStorage _localFileStorage;

  Future<CharacterExportResult> exportToDirectory(
    String parentPath, {
    void Function(CharacterImportProgress progress)? onProgress,
  }) async {
    final characters = await _characterRepository.getCharacters();
    final lists = await _rankingListRepository.getLists();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final exportDirectory = Directory(
      p.join(parentPath, 'mycharacterlist_export_$timestamp'),
    );
    await exportDirectory.create(recursive: true);

    final exportData = await buildCharactersExportData(
      characters,
      exportDirectory: exportDirectory,
      onProgress: onProgress,
    );

    final listJson = <Map<String, dynamic>>[];
    for (var index = 0; index < lists.length; index++) {
      onProgress?.call(
        CharacterImportProgress(
          completed: index,
          total: lists.length,
          phase: CharacterImportPhase.exportLists,
        ),
      );

      final list = lists[index];
      final rankedCharacters = await _rankingListRepository.getRankedCharacters(
        list.id,
      );

      listJson.add({
        ...RankingListModel.fromEntity(list).toJson(),
        'characters': rankedCharacters
            .map(
              (rankedCharacter) => {
                'characterId': rankedCharacter.characterId,
                'position': rankedCharacter.position,
              },
            )
            .toList(),
      });

      onProgress?.call(
        CharacterImportProgress(
          completed: index + 1,
          total: lists.length,
          phase: CharacterImportPhase.exportLists,
        ),
      );
    }

    final patchJson = await _buildPatchesJson(onProgress: onProgress);

    final jsonFile = File(p.join(exportDirectory.path, 'data.json'));
    const encoder = JsonEncoder.withIndent('  ');
    await jsonFile.writeAsString(
      encoder.convert({
        'schemaVersion': 1,
        'characters': exportData.characterJson,
        'lists': listJson,
        'patches': patchJson,
      }),
    );

    return CharacterExportResult(
      directoryPath: exportDirectory.path,
      characters: characters.length,
      lists: lists.length,
      patches: patchJson.length,
      images: exportData.exportedImages,
      missingImages: exportData.missingImages,
    );
  }

  Future<List<Map<String, dynamic>>> _buildPatchesJson({
    void Function(CharacterImportProgress progress)? onProgress,
  }) async {
    final lists = await _rankingListRepository.getLists();
    final patches = <RankingListPatch>[];

    for (final list in lists) {
      patches.addAll(await _patchRepository.getPatchesForList(list.id));
    }

    final patchJson = <Map<String, dynamic>>[];
    for (var index = 0; index < patches.length; index++) {
      onProgress?.call(
        CharacterImportProgress(
          completed: index,
          total: patches.length,
          phase: CharacterImportPhase.exportPatches,
        ),
      );

      final patch = patches[index];
      final entries = await _patchRepository.getPatchEntries(patch.id);
      patchJson.add({
        ...RankingListPatchModel.fromEntity(patch).toJson(),
        'entries': entries
            .map(
              (entry) => RankingListPatchEntryModel.fromEntity(entry).toJson(),
            )
            .toList(),
      });
    }

    if (patches.isNotEmpty) {
      onProgress?.call(
        CharacterImportProgress(
          completed: patches.length,
          total: patches.length,
          phase: CharacterImportPhase.exportPatches,
        ),
      );
    }

    return patchJson;
  }

  Future<CharacterSubsetExportData> buildCharactersExportData(
    List<Character> characters, {
    required Directory exportDirectory,
    void Function(CharacterImportProgress progress)? onProgress,
  }) async {
    var exportedImages = 0;
    var missingImages = 0;
    final characterJson = <Map<String, dynamic>>[];
    final total = characters.length;

    for (var index = 0; index < characters.length; index++) {
      onProgress?.call(
        CharacterImportProgress(
          completed: index,
          total: total,
          phase: CharacterImportPhase.exportCharacters,
        ),
      );

      final character = characters[index];
      final mainImage = await _copyImage(
        sourcePath: character.mainImagePath,
        exportDirectory: exportDirectory,
        characterId: character.id,
        fileName: 'main',
      );
      if (character.mainImagePath != null) {
        if (mainImage == null) {
          missingImages++;
        } else {
          exportedImages++;
        }
      }

      final galleryImages = <String>[];
      for (var index = 0; index < character.galleryImagePaths.length; index++) {
        final image = await _copyImage(
          sourcePath: character.galleryImagePaths[index],
          exportDirectory: exportDirectory,
          characterId: character.id,
          fileName: 'gallery_$index',
        );
        if (image == null) {
          missingImages++;
        } else {
          exportedImages++;
          galleryImages.add(image);
        }
      }

      characterJson.add(
        _characterToJson(
          character,
          mainImage: mainImage,
          mainImageData: await _imageData(
            character.mainImagePath,
            characterId: character.id,
          ),
          galleryImages: galleryImages,
          galleryImageData: await _galleryImageData(
            character.galleryImagePaths,
            characterId: character.id,
          ),
        ),
      );

      await _exportCompressedManifest(
        characterId: character.id,
        exportDirectory: exportDirectory,
      );

      onProgress?.call(
        CharacterImportProgress(
          completed: index + 1,
          total: total,
          phase: CharacterImportPhase.exportCharacters,
        ),
      );
    }

    return CharacterSubsetExportData(
      characterJson: characterJson,
      exportedImages: exportedImages,
      missingImages: missingImages,
    );
  }

  Map<String, dynamic> _characterToJson(
    Character character, {
    required String? mainImage,
    required Map<String, dynamic>? mainImageData,
    required List<String> galleryImages,
    required List<Map<String, dynamic>> galleryImageData,
  }) {
    return {
      'id': character.id,
      'name': character.name,
      'sourceTitle': character.sourceTitle,
      'description': character.description,
      'age': character.age,
      'height': character.height,
      'japaneseName': character.japaneseName,
      'archetype': character.archetype,
      'gender': character.gender,
      'personalNotes': character.personalNotes,
      'mainImage': mainImage ?? '',
      'mainImageData': mainImageData,
      'galleryImages': galleryImages,
      'galleryImageData': galleryImageData,
      'grades': character.grades,
      'facts': character.facts
          .map((fact) => CharacterFactModel.fromEntity(fact).toJson())
          .toList(),
    };
  }

  Future<List<Map<String, dynamic>>> _galleryImageData(
    List<String> paths, {
    required String characterId,
  }) async {
    final images = <Map<String, dynamic>>[];
    for (final path in paths) {
      final data = await _imageData(path, characterId: characterId);
      if (data != null) {
        images.add(data);
      }
    }
    return images;
  }

  Future<Map<String, dynamic>?> _imageData(
    String? path, {
    required String characterId,
  }) async {
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final resolvedPath = await _localFileStorage.resolveExistingImagePath(
      path,
      characterFolder: characterId,
    );
    if (resolvedPath == null) {
      return null;
    }

    final file = File(resolvedPath);
    final isCompressed = await _localFileStorage.isImageCompressed(
      characterId,
      resolvedPath,
    );

    return {
      'extension': p.extension(file.path),
      'base64': base64Encode(await file.readAsBytes()),
      if (isCompressed) 'compressed': true,
    };
  }

  Future<String?> _copyImage({
    required String? sourcePath,
    required Directory exportDirectory,
    required String characterId,
    required String fileName,
  }) async {
    if (sourcePath == null || sourcePath.trim().isEmpty) {
      return null;
    }

    final resolvedPath = await _localFileStorage.resolveExistingImagePath(
      sourcePath,
      characterFolder: characterId,
    );
    if (resolvedPath == null) {
      return null;
    }

    final source = File(resolvedPath);

    final extension = p.extension(source.path);
    final relativePath = p.join(
      'images',
      _safePathSegment(characterId),
      '$fileName$extension',
    );
    final destination = File(p.join(exportDirectory.path, relativePath));
    await destination.parent.create(recursive: true);
    await source.copy(destination.path);

    return relativePath.replaceAll(r'\', '/');
  }

  Future<void> _exportCompressedManifest({
    required String characterId,
    required Directory exportDirectory,
  }) async {
    final character = await _characterRepository.getCharacterById(characterId);
    if (character == null) {
      return;
    }

    final exportCompressed = <String>{};

    if (character.mainImagePath != null &&
        await _localFileStorage.isImageCompressed(
          characterId,
          character.mainImagePath,
        )) {
      exportCompressed.add('main${p.extension(character.mainImagePath!)}');
    }

    for (var index = 0; index < character.galleryImagePaths.length; index++) {
      final path = character.galleryImagePaths[index];
      if (await _localFileStorage.isImageCompressed(characterId, path)) {
        exportCompressed.add('gallery_$index${p.extension(path)}');
      }
    }

    if (exportCompressed.isEmpty) {
      return;
    }

    final destinationDirectory = Directory(
      p.join(
        exportDirectory.path,
        'images',
        _safePathSegment(characterId),
      ),
    );
    await CompressedImagesManifest.write(destinationDirectory, exportCompressed);
  }

  String _safePathSegment(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }
}

class CharacterSubsetExportData {
  const CharacterSubsetExportData({
    required this.characterJson,
    required this.exportedImages,
    required this.missingImages,
  });

  final List<Map<String, dynamic>> characterJson;
  final int exportedImages;
  final int missingImages;
}
