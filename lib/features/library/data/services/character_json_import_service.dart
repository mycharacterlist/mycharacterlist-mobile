import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:path/path.dart' as p;

import 'package:mycharacterlist/core/storage/compressed_images_manifest.dart';
import 'package:mycharacterlist/core/storage/local_file_storage.dart';
import 'package:mycharacterlist/features/characters/data/models/character_fact_model.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character_gender.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_reference_repository.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_repository.dart';
import 'package:mycharacterlist/features/library/domain/entities/character_import_progress.dart';
import 'package:mycharacterlist/features/library/domain/entities/character_import_result.dart';
import 'package:mycharacterlist/features/ranking_lists/data/models/ranking_list_model.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/repositories/ranking_list_repository.dart';

class CharacterJsonImportService {
  const CharacterJsonImportService({
    required CharacterRepository characterRepository,
    required CharacterReferenceRepository referenceRepository,
    required RankingListRepository rankingListRepository,
    required LocalFileStorage localFileStorage,
  }) : _characterRepository = characterRepository,
       _referenceRepository = referenceRepository,
       _rankingListRepository = rankingListRepository,
       _localFileStorage = localFileStorage;

  final CharacterRepository _characterRepository;
  final CharacterReferenceRepository _referenceRepository;
  final RankingListRepository _rankingListRepository;
  final LocalFileStorage _localFileStorage;

  Future<CharacterImportResult> importFile(
    String filePath, {
    void Function(CharacterImportProgress progress)? onProgress,
  }) async {
    final file = File(filePath);
    final decoded = jsonDecode(await file.readAsString());

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unsupported import format.');
    }

    if (decoded['schemaVersion'] != 1) {
      throw const FormatException('Unsupported import format.');
    }

    final rawCharacters = decoded['characters'];
    if (rawCharacters is! List) {
      throw const FormatException('The characters field must be a list.');
    }

    final characterResult = await importCharactersFromList(
      rawCharacters,
      jsonFile: file,
      onProgress: onProgress,
    );

    final rawLists = decoded['lists'];
    if (rawLists == null) {
      return characterResult;
    }

    if (rawLists is! List) {
      throw const FormatException('The lists field must be a list.');
    }

    if (rawLists.isEmpty) {
      return characterResult;
    }

    final listResult = await _importLists(
      rawLists,
      onProgress: onProgress,
    );
    return CharacterImportResult(
      created: characterResult.created,
      updated: characterResult.updated,
      failed: characterResult.failed,
      listsCreated: listResult.listsCreated,
      listsUpdated: listResult.listsUpdated,
      listsFailed: listResult.listsFailed,
      missingListCharacters: listResult.missingListCharacters,
    );
  }

  Future<({
    int listsCreated,
    int listsUpdated,
    int listsFailed,
    int missingListCharacters,
  })> _importLists(
    List<dynamic> rawLists, {
    void Function(CharacterImportProgress progress)? onProgress,
  }) async {
    var listsCreated = 0;
    var listsUpdated = 0;
    var listsFailed = 0;
    var missingListCharacters = 0;

    for (var index = 0; index < rawLists.length; index++) {
      onProgress?.call(
        CharacterImportProgress(
          completed: index,
          total: rawLists.length,
          phase: CharacterImportPhase.lists,
        ),
      );

      final rawList = rawLists[index];
      try {
        if (rawList is! Map) {
          throw const FormatException('List must be an object.');
        }

        final json = Map<String, dynamic>.from(rawList);
        final list = RankingListModel.fromJson(json);
        final existing = await _rankingListRepository.getListById(list.id);

        await _rankingListRepository.saveList(list);
        if (existing == null) {
          listsCreated++;
        } else {
          listsUpdated++;
        }

        final rawEntries = json['characters'];
        if (rawEntries is! List) {
          throw const FormatException('List characters must be an array.');
        }

        final entries = <({String characterId, int position})>[];
        for (final rawEntry in rawEntries) {
          if (rawEntry is! Map) {
            throw const FormatException('List character entry must be an object.');
          }

          final entry = Map<String, dynamic>.from(rawEntry);
          final characterId = entry['characterId']?.toString().trim() ?? '';
          final position = entry['position'] is int
              ? entry['position'] as int
              : int.tryParse(entry['position']?.toString() ?? '');

          if (characterId.isEmpty || position == null || position < 1) {
            throw const FormatException('Invalid list character entry.');
          }

          final character = await _characterRepository.getCharacterById(
            characterId,
          );
          if (character == null) {
            missingListCharacters++;
            continue;
          }

          entries.add((characterId: characterId, position: position));
        }

        await _rankingListRepository.replaceListCharacters(
          listId: list.id,
          entries: entries,
        );
      } catch (_) {
        listsFailed++;
      }

      onProgress?.call(
        CharacterImportProgress(
          completed: index + 1,
          total: rawLists.length,
          phase: CharacterImportPhase.lists,
        ),
      );
    }

    return (
      listsCreated: listsCreated,
      listsUpdated: listsUpdated,
      listsFailed: listsFailed,
      missingListCharacters: missingListCharacters,
    );
  }

  Future<CharacterImportResult> importCharactersFromList(
    List<dynamic> rawCharacters, {
    required File jsonFile,
    void Function(CharacterImportProgress progress)? onProgress,
  }) async {
    final gradeDefinitions = await _referenceRepository.getGradeDefinitions();
    final gradeMaximums = {
      for (final definition in gradeDefinitions)
        definition.id: definition.maxValue,
    };
    var created = 0;
    var updated = 0;
    var failed = 0;
    final total = rawCharacters.length;

    for (var index = 0; index < rawCharacters.length; index++) {
      onProgress?.call(
        CharacterImportProgress(
          completed: index,
          total: total,
          phase: CharacterImportPhase.characters,
        ),
      );

      final rawCharacter = rawCharacters[index];
      try {
        if (rawCharacter is! Map) {
          throw const FormatException('Character must be an object.');
        }

        final json = Map<String, dynamic>.from(rawCharacter);
        final id = _requiredString(json, 'id');
        final existing = await _characterRepository.getCharacterById(id);

        final sourceTitle = await _referenceRepository.ensureAnimeTitle(
          _requiredString(json, 'sourceTitle'),
        );

        final archetype = _optionalString(json, 'archetype');
        if (archetype.isNotEmpty &&
            !await _referenceRepository.containsArchetype(archetype)) {
          await _referenceRepository.addArchetype(archetype);
        }

        final now = DateTime.now();
        final exportCompressedFiles = await _readExportCompressedManifest(
          jsonFile,
          id,
        );
        final embeddedMainImage = await _restoreEmbeddedImage(
          json['mainImageData'],
          folder: id,
        );
        final character = Character(
          id: id,
          name: _requiredString(json, 'name'),
          sourceTitle: sourceTitle,
          description: _stringOrExisting(
            json,
            'description',
            existing?.description,
          ),
          age: _stringOrExisting(json, 'age', existing?.age),
          height: _stringOrExisting(json, 'height', existing?.height),
          japaneseName: _stringOrExisting(
            json,
            'japaneseName',
            existing?.japaneseName,
          ),
          archetype: json.containsKey('archetype')
              ? archetype
              : existing?.archetype ?? '',
          gender: json.containsKey('gender')
              ? CharacterGender.normalize(_optionalString(json, 'gender'))
              : existing?.gender ?? CharacterGender.unknown,
          personalNotes: _stringOrExisting(
            json,
            'personalNotes',
            existing?.personalNotes,
          ),
          mainImagePath:
              json.containsKey('mainImage') || json.containsKey('mainImageData')
              ? embeddedMainImage ??
                    await _importImageFromJsonPath(
                      jsonFile,
                      json['mainImage'],
                      folder: id,
                      compressedFiles: exportCompressedFiles,
                    )
              : existing?.mainImagePath,
          galleryImagePaths:
              json.containsKey('galleryImages') ||
                  json.containsKey('galleryImageData')
              ? await _importGalleryImages(
                  jsonFile,
                  json['galleryImages'],
                  json['galleryImageData'],
                  folder: id,
                  compressedFiles: exportCompressedFiles,
                )
              : existing?.galleryImagePaths ?? const [],
          grades: json.containsKey('grades')
              ? _parseGrades(json['grades'], gradeMaximums)
              : existing?.grades ?? const {},
          facts: json.containsKey('facts')
              ? _parseFacts(json['facts'])
              : existing?.facts ?? const [],
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
        );

        await _characterRepository.saveCharacter(character);
        if (existing == null) {
          created++;
        } else {
          updated++;
        }
      } catch (_) {
        failed++;
      }

      onProgress?.call(
        CharacterImportProgress(
          completed: index + 1,
          total: total,
          phase: CharacterImportPhase.characters,
        ),
      );
    }

    await _referenceRepository.deleteUnusedAnimeTitles();

    return CharacterImportResult(
      created: created,
      updated: updated,
      failed: failed,
    );
  }

  Future<String?> _restoreEmbeddedImage(
    Object? rawImage, {
    required String folder,
  }) async {
    if (rawImage is! Map) {
      return null;
    }

    final image = Map<String, dynamic>.from(rawImage);
    final encoded = image['base64']?.toString() ?? '';
    if (encoded.isEmpty) {
      return null;
    }

    return _localFileStorage.saveImportedImageBytes(
      base64Decode(encoded),
      folder: folder,
      extension: image['extension']?.toString() ?? '',
      alreadyCompressed: image['compressed'] == true,
    );
  }

  Future<String?> _importImageFromJsonPath(
    File jsonFile,
    Object? rawPath, {
    required String folder,
    Set<String> compressedFiles = const {},
  }) async {
    final sourcePath = _resolveOptionalPath(jsonFile, rawPath);
    if (sourcePath == null) {
      return null;
    }

    final resolvedPath = await _localFileStorage.resolveExistingImagePath(
      sourcePath,
      characterFolder: folder,
    );
    if (resolvedPath == null) {
      return null;
    }

    try {
      final savedPath = await _localFileStorage.saveFile(
        resolvedPath,
        folder: folder,
        compress: false,
      );
      if (compressedFiles.contains(p.basename(resolvedPath))) {
        await _localFileStorage.markImageAsCompressed(folder, savedPath);
      }
      return savedPath;
    } on Object {
      return null;
    }
  }

  Future<List<String>> _importGalleryImages(
    File jsonFile,
    Object? rawPaths,
    Object? rawEmbedded, {
    required String folder,
    Set<String> compressedFiles = const {},
  }) async {
    final pathEntries = rawPaths is List
        ? rawPaths.map((path) => path.toString().trim()).toList()
        : const <String>[];
    final embeddedEntries = rawEmbedded is List ? rawEmbedded : const <dynamic>[];
    final count = math.max(pathEntries.length, embeddedEntries.length);
    final importedPaths = <String>[];

    for (var index = 0; index < count; index++) {
      String? importedPath;

      if (index < embeddedEntries.length) {
        importedPath = await _restoreEmbeddedImage(
          embeddedEntries[index],
          folder: folder,
        );
      }

      if (importedPath == null && index < pathEntries.length) {
        importedPath = await _importImageFromJsonPath(
          jsonFile,
          pathEntries[index],
          folder: folder,
          compressedFiles: compressedFiles,
        );
      }

      if (importedPath != null) {
        importedPaths.add(importedPath);
      }
    }

    return importedPaths;
  }

  Future<Set<String>> _readExportCompressedManifest(
    File jsonFile,
    String characterId,
  ) async {
    final manifestFile = File(
      p.join(
        jsonFile.parent.path,
        'images',
        _safePathSegment(characterId),
        CompressedImagesManifest.fileName,
      ),
    );

    return CompressedImagesManifest.readFromFile(manifestFile);
  }

  String _safePathSegment(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }

  String _requiredString(Map<String, dynamic> json, String key) {
    final value = _optionalString(json, key);
    if (value.isEmpty) {
      throw FormatException('$key cannot be empty.');
    }
    return value;
  }

  String _optionalString(Map<String, dynamic> json, String key) {
    return json[key]?.toString().trim() ?? '';
  }

  String _stringOrExisting(
    Map<String, dynamic> json,
    String key,
    String? existing,
  ) {
    return json.containsKey(key) ? _optionalString(json, key) : existing ?? '';
  }

  String? _resolveOptionalPath(File jsonFile, Object? rawPath) {
    final path = rawPath?.toString().trim() ?? '';
    return path.isEmpty ? null : _resolvePath(jsonFile, path);
  }

  String _resolvePath(File jsonFile, String path) {
    return p.isAbsolute(path)
        ? p.normalize(path)
        : p.normalize(p.join(jsonFile.parent.path, path));
  }

  Map<String, int> _parseGrades(
    Object? rawGrades,
    Map<String, int> gradeMaximums,
  ) {
    if (rawGrades is! Map) {
      return const {};
    }

    final grades = <String, int>{};
    for (final entry in rawGrades.entries) {
      final id = entry.key.toString();
      final maximum = gradeMaximums[id];
      final value = entry.value is int
          ? entry.value as int
          : int.tryParse(entry.value.toString());

      if (maximum == null || value == null || value < 0 || value > maximum) {
        throw FormatException('Invalid grade: $id.');
      }
      grades[id] = value;
    }
    return grades;
  }

  List<CharacterFactModel> _parseFacts(Object? rawFacts) {
    if (rawFacts is! List) {
      return const [];
    }

    return rawFacts
        .map(
          (fact) => CharacterFactModel.fromJson(
            Map<String, dynamic>.from(fact as Map),
          ),
        )
        .toList();
  }
}
