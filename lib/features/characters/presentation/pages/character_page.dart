import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/bootstrap/app_image_cache.dart';
import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_indicator.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_message_view.dart';
import 'package:mycharacterlist/core/errors/app_messages.dart';
import 'package:mycharacterlist/app/widgets/layout/framed_content_panel.dart';
import 'package:mycharacterlist/app/widgets/layout/screen_scaffold.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/features/characters/character_providers.dart';
import 'package:mycharacterlist/features/library/library_providers.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character_ranking_display.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_facts.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_gallery.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_main_information.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_personal_grades.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_personal_notes.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_ranks_standing.dart';

class CharacterPage extends ConsumerStatefulWidget {
  const CharacterPage({
    super.key,
    required this.characterId,
  });

  final String characterId;

  @override
  ConsumerState<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends ConsumerState<CharacterPage> {
  @override
  void dispose() {
    AppImageCache.trimAfterHeavyScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterAsync = ref.watch(characterByIdProvider(widget.characterId));
    final gradeDefinitionsAsync = ref.watch(gradeDefinitionsProvider);
    final rankingsAsync =
        ref.watch(characterRankingDisplaysProvider(widget.characterId));
    final canEdit = characterAsync.maybeWhen(
      data: (character) => character != null,
      orElse: () => false,
    );

    return ScreenScaffold(
      appBar: CustomAppBar(
        title: 'Character page',
        backgroundColor: AppColors.characterAppBarBackground,
        backButtonColor: Colors.black,
        titleColor: Colors.black,
        actionWidget: canEdit
            ? IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: () async {
                  await context.push(
                    AppRoutes.characterEditById(widget.characterId),
                  );
                  if (!context.mounted) {
                    return;
                  }
                  await refreshLibraryAfterCharacterMutation(
                    ref,
                    characterId: widget.characterId,
                  );
                },
              )
            : null,
      ),
      backgroundAssetPath: AppBackgroundAssets.characterPage,
      child: FramedContentPanel(
        frameAssetPath: AppBackgroundAssets.characterFrame,
        child: characterAsync.when(
          loading: () => const AppLoadingIndicator(),
          error: (_, __) => const AppMessageView(
            message: AppMessages.couldNotLoadCharacter,
          ),
          data: (character) {
            if (character == null) {
              return const AppMessageView(
                message: AppMessages.characterNotFound,
              );
            }

            return gradeDefinitionsAsync.when(
              loading: () => const AppLoadingIndicator(),
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
          CharacterGallery(
            characterId: character.id,
            imagePaths: character.galleryImagePaths,
          ),
          if (character.facts.isNotEmpty) ...[
            const SizedBox(height: 12),
            CharacterFacts(facts: character.facts),
          ],
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.only(
              bottom: 12 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: CharacterPersonalNotes(notes: character.personalNotes),
          ),
        ],
      ),
    );
  }
}
