import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_indicator.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_overlay.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_message_view.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/layout/bottom_action_slot.dart';
import 'package:mycharacterlist/app/widgets/layout/screen_scaffold.dart';
import 'package:mycharacterlist/core/errors/app_messages.dart';
import 'package:mycharacterlist/core/presentation/feedback/app_snack_bar.dart';
import 'package:mycharacterlist/features/characters/character_providers.dart';
import 'package:mycharacterlist/features/gallery/data/repositories/gallery_repository_providers.dart';
import 'package:mycharacterlist/features/gallery/gallery_providers.dart';
import 'package:mycharacterlist/features/gallery/presentation/widgets/character_gallery_picker.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/Plus_button.dart';

class CharacterGalleryPage extends ConsumerStatefulWidget {
  const CharacterGalleryPage({
    super.key,
    required this.characterId,
  });

  final String characterId;

  @override
  ConsumerState<CharacterGalleryPage> createState() =>
      _CharacterGalleryPageState();
}

class _CharacterGalleryPageState extends ConsumerState<CharacterGalleryPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isSaving = false;
  int _savingCompleted = 0;
  int _savingTotal = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterAsync = ref.watch(characterByIdProvider(widget.characterId));

    return ScreenScaffold(
      backgroundAssetPath: AppBackgroundAssets.gallery,
      appBar: CustomAppBar(
        title: 'Gallery page',
        backgroundColor: const Color(0xFF024818),
        titleColor: Colors.white,
        backButtonColor: Colors.black,
      ),
      overlays: [
        BottomActionSlot(
          bottomMargin: 25,
          child: PlusButton(
            icon: const Icon(
              Icons.add,
              size: 40,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ),
        if (_isSaving)
          AppLoadingOverlay(
            title: 'Adding photos...',
            completed: _savingCompleted,
            total: _savingTotal,
          ),
      ],
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.95,
          height: MediaQuery.sizeOf(context).height * 0.87,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  AppBackgroundAssets.characterFrame,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned.fill(
                top: 0,
                left: 5,
                right: 5,
                bottom: 130,
                child: characterAsync.when(
                  loading: () => const AppLoadingIndicator(),
                  error: (_, __) => const AppMessageView(
                    message: AppMessages.couldNotLoadCharacter,
                  ),
                  data: (character) {
                    final loadedCharacter = character;
                    if (loadedCharacter == null) {
                      return const AppMessageView(
                        message: AppMessages.characterNotFound,
                      );
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          loadedCharacter.name,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          style: const TextStyle(
                            fontSize: 32,
                            height: 1.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'DoublePicaREG',
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            thickness: 4,
                            radius: const Radius.circular(8),
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: CharacterGalleryPicker(
                                characterId: loadedCharacter.id,
                                imagePaths: loadedCharacter.galleryImagePaths,
                                isSaving: _isSaving,
                                onAddImages: _addGalleryImages,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addGalleryImages(List<String> imagePaths) async {
    if (_isSaving || imagePaths.isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
      _savingCompleted = 0;
      _savingTotal = imagePaths.length;
    });

    try {
      await ref.read(galleryRepositoryProvider).addGalleryImages(
        characterId: widget.characterId,
        imagePaths: imagePaths,
        onProgress: (completed, total) {
          if (mounted) {
            setState(() {
              _savingCompleted = completed;
              _savingTotal = total;
            });
          }
        },
      );
      ref.invalidate(characterByIdProvider(widget.characterId));
      ref.invalidate(characterGalleryImagesProvider(widget.characterId));
    } catch (_) {
      if (mounted) {
        AppSnackBar.showCentered(context, AppMessages.couldNotSaveCharacter);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _savingCompleted = 0;
          _savingTotal = 0;
        });
      }
    }
  }
}
