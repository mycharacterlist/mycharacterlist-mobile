import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:mycharacterlist/features/characters/data/models/character_fact_model.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_repository.dart';
import 'package:mycharacterlist/features/library/domain/entities/character_export_result.dart';
import 'package:mycharacterlist/features/ranking_lists/data/models/ranking_list_model.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/repositories/ranking_list_repository.dart';

class CharacterJsonExportService {
  const CharacterJsonExportService({
    required CharacterRepository characterRepository,
    required RankingListRepository rankingListRepository,
  }) : _characterRepository = characterRepository,
       _rankingListRepository = rankingListRepository;

  final CharacterRepository _characterRepository;
  final RankingListRepository _rankingListRepository;

  Future<CharacterExportResult> exportToDirectory(String parentPath) async {
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
    );

    final listJson = <Map<String, dynamic>>[];
    for (final list in lists) {
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
    }

    final jsonFile = File(p.join(exportDirectory.path, 'data.json'));
    const encoder = JsonEncoder.withIndent('  ');
    await jsonFile.writeAsString(
      encoder.convert({
        'schemaVersion': 1,
        'characters': exportData.characterJson,
        'lists': listJson,
      }),
    );

    return CharacterExportResult(
      directoryPath: exportDirectory.path,
      characters: characters.length,
      lists: lists.length,
      images: exportData.exportedImages,
      missingImages: exportData.missingImages,
    );
  }

  Future<CharacterSubsetExportData> buildCharactersExportData(
    List<Character> characters, {
    required Directory exportDirectory,
  }) async {
    var exportedImages = 0;
    var missingImages = 0;
    final characterJson = <Map<String, dynamic>>[];

    for (final character in characters) {
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
          mainImageData: await _imageData(character.mainImagePath),
          galleryImages: galleryImages,
          galleryImageData: await _galleryImageData(
            character.galleryImagePaths,
          ),
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
    required Map<String, String>? mainImageData,
    required List<String> galleryImages,
    required List<Map<String, String>> galleryImageData,
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

  Future<List<Map<String, String>>> _galleryImageData(
    List<String> paths,
  ) async {
    final images = <Map<String, String>>[];
    for (final path in paths) {
      final data = await _imageData(path);
      if (data != null) {
        images.add(data);
      }
    }
    return images;
  }

  Future<Map<String, String>?> _imageData(String? path) async {
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final file = File(path);
    if (!await file.exists()) {
      return null;
    }

    return {
      'extension': p.extension(file.path),
      'base64': base64Encode(await file.readAsBytes()),
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

    final source = File(sourcePath);
    if (!await source.exists()) {
      return null;
    }

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
