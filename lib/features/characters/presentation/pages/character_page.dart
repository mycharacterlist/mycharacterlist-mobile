import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/app/widgets/app_appbar.dart';
import 'package:mycharacterlist/features/characters/character_providers.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';
import 'package:mycharacterlist/features/characters/presentation/models/character_ranking_display.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_facts.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_gallery.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_main_information.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_personal_grades.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_personal_notes.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_ranks_standing.dart';

class CharacterPage extends ConsumerWidget {
  const CharacterPage({
    super.key,
    required this.characterId,
  });

  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterAsync = ref.watch(characterByIdProvider(characterId));
    final gradeDefinitionsAsync = ref.watch(gradeDefinitionsProvider);
    final rankingsAsync = ref.watch(characterRankingDisplaysProvider(characterId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Character page',
        backgroundColor: const Color(0xFF315B8B),
        backButtonColor: Colors.black,
        titleColor: Colors.black,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/CharacterPage_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.87,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/cropped_rectangle.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 8,
                    right: 8,
                    bottom: 20,
                    child: characterAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Center(
                        child: Text(
                          'Could not load character',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      data: (character) {
                        if (character == null) {
                          return const Center(
                            child: Text(
                              'Character not found',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }

                        return gradeDefinitionsAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (_, __) => _CharacterContent(
                            character: character,
                            definitions: const [],
                            rankings: rankingsAsync.valueOrNull ?? const [],
                          ),
                          data: (definitions) => rankingsAsync.when(
                            loading: () => _CharacterContent(
                              character: character,
                              definitions: definitions,
                              rankings: const [],
                            ),
                            error: (_, __) => _CharacterContent(
                              character: character,
                              definitions: definitions,
                              rankings: const [],
                            ),
                            data: (rankings) => _CharacterContent(
                              character: character,
                              definitions: definitions,
                              rankings: rankings,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterContent extends StatelessWidget {
  const _CharacterContent({
    required this.character,
    required this.definitions,
    required this.rankings,
  });

  final Character character;
  final List<GradeDefinition> definitions;
  final List<CharacterRankingDisplay> rankings;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              character.name,
              textAlign: TextAlign.center,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              style: const TextStyle(
                fontSize: 36,
                height: 1.0,
                color: Colors.black,
                fontFamily: 'DoublePicaREG',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 11),
          CharacterMainInformation(character: character),
          const SizedBox(height: 12),
          CharacterPersonalGrades(
            definitions: definitions,
            grades: character.grades,
          ),
          const SizedBox(height: 12),
          CharacterRanksStanding(rankings: rankings),
          const SizedBox(height: 12),
          CharacterGallery(imagePaths: character.galleryImagePaths),
          if (character.facts.isNotEmpty) ...[
            const SizedBox(height: 12),
            CharacterFacts(facts: character.facts),
          ],
          const SizedBox(height: 12),
          CharacterPersonalNotes(notes: character.personalNotes),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
