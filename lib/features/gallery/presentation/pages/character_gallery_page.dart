import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
  static const double _actionButtonBottomMargin = 25;
  static const double _actionButtonTopMargin = 25;
  static const double _actionButtonClearance =
      _actionButtonBottomMargin +
      BottomActionSlot.defaultButtonHeight +
      _actionButtonTopMargin;

  final ScrollController _scrollController = ScrollController();
  bool _isSaving = false;
  bool _isEditMode = false;
  bool _isPersistingOrder = false;
  bool _isPersistingRemoval = false;
  bool _hasGalleryChanges = false;
  String _loadingTitle = 'Adding photos...';
  List<String>? _localImagePaths;
  int _savingCompleted = 0;
  int _savingTotal = 0;

  @override
  void dispose() {
    if (_hasGalleryChanges) {
      ref.invalidate(characterByIdProvider(widget.characterId));
      ref.invalidate(characterGalleryImagesProvider(widget.characterId));
    }
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
        backButtonColor: Colors.white,
        actionWidget: IconButton(
          onPressed: _isSaving
              ? null
              : () => setState(() => _isEditMode = !_isEditMode),
          icon: Icon(_isEditMode ? Icons.close : Icons.edit),
          color: Colors.white,
          tooltip: _isEditMode ? 'Cancel editing' : 'Edit gallery',
        ),
      ),
      overlays: [
        if (_isSaving)
          AppLoadingOverlay(
            title: _loadingTitle,
            completed: _savingCompleted,
            total: _savingTotal,
          ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          const panelBottomMargin = 8.0;
          final bottomInset = MediaQuery.paddingOf(context).bottom;
          final maxPanelHeight =
              constraints.maxHeight - bottomInset - panelBottomMargin;
          final preferredPanelHeight = MediaQuery.sizeOf(context).height * 0.87;
          final panelHeight = preferredPanelHeight > maxPanelHeight
              ? maxPanelHeight
              : preferredPanelHeight;

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.95,
              height: panelHeight,
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
                    bottom: _actionButtonClearance,
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
                        final imagePaths =
                            _localImagePaths ??
                            loadedCharacter.galleryImagePaths;

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
                              child: ScrollbarTheme(
                                data: ScrollbarTheme.of(context).copyWith(
                                  thumbColor: MaterialStateProperty.all(
                                    Colors.black.withValues(alpha: 0.55),
                                  ),
                                ),
                                child: Scrollbar(
                                  controller: _scrollController,
                                  thumbVisibility: true,
                                  thickness: 6,
                                  radius: const Radius.circular(8),
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: CharacterGalleryPicker(
                                      characterId: loadedCharacter.id,
                                      imagePaths: imagePaths,
                                      isSaving: _isSaving,
                                      isEditMode: _isEditMode,
                                      onAddPressed: _pickGalleryImages,
                                      onRemoveImage: _removeGalleryImage,
                                      onReorderImage: _reorderGalleryImage,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: _actionButtonBottomMargin,
                    child: Center(
                      child: PlusButton(
                        icon: const Icon(
                          Icons.add,
                          size: 40,
                          color: Colors.white,
                        ),
                        onPressed: _pickGalleryImages,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickGalleryImages() async {
    if (_isSaving) {
      return;
    }

    final picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images.isEmpty || !mounted) {
      return;
    }

    await _addGalleryImages(
      images.map((image) => image.path).toList(),
    );
  }

  Future<void> _addGalleryImages(List<String> imagePaths) async {
    if (_isSaving || imagePaths.isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
      _loadingTitle = 'Adding photos...';
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
          _localImagePaths = null;
          _savingCompleted = 0;
          _savingTotal = 0;
        });
      }
    }
  }

  Future<void> _removeGalleryImage(int imageIndex) async {
    if (_isSaving || _isPersistingRemoval) {
      return;
    }

    final character = ref
        .read(characterByIdProvider(widget.characterId))
        .valueOrNull;
    if (character == null) {
      return;
    }

    final previousPaths = [
      ...(_localImagePaths ?? character.galleryImagePaths),
    ];
    if (imageIndex < 0 || imageIndex >= previousPaths.length) {
      return;
    }

    final updatedPaths = [...previousPaths]..removeAt(imageIndex);

    setState(() {
      _isPersistingRemoval = true;
      _localImagePaths = updatedPaths;
    });

    try {
      await ref.read(galleryRepositoryProvider).updateGalleryImagePaths(
        characterId: widget.characterId,
        imagePaths: updatedPaths,
      );
      _hasGalleryChanges = true;
    } catch (_) {
      if (mounted) {
        setState(() => _localImagePaths = previousPaths);
        AppSnackBar.showCentered(context, AppMessages.couldNotSaveCharacter);
      }
    } finally {
      if (mounted) {
        setState(() => _isPersistingRemoval = false);
      }
    }
  }

  Future<void> _reorderGalleryImage(int fromIndex, int toIndex) async {
    if (_isSaving || _isPersistingOrder || fromIndex == toIndex) {
      return;
    }

    final character = ref
        .read(characterByIdProvider(widget.characterId))
        .valueOrNull;
    if (character == null) {
      return;
    }

    final previousPaths = [
      ...(_localImagePaths ?? character.galleryImagePaths),
    ];
    if (fromIndex < 0 ||
        fromIndex >= previousPaths.length ||
        toIndex < 0 ||
        toIndex >= previousPaths.length) {
      return;
    }

    final updatedPaths = [...previousPaths];
    final movedPath = updatedPaths.removeAt(fromIndex);
    updatedPaths.insert(toIndex, movedPath);

    setState(() {
      _isPersistingOrder = true;
      _localImagePaths = updatedPaths;
    });

    try {
      await ref.read(galleryRepositoryProvider).updateGalleryImagePaths(
        characterId: widget.characterId,
        imagePaths: updatedPaths,
      );
      _hasGalleryChanges = true;
    } catch (_) {
      if (mounted) {
        setState(() => _localImagePaths = previousPaths);
        AppSnackBar.showCentered(context, AppMessages.couldNotSaveCharacter);
      }
    } finally {
      if (mounted) {
        setState(() => _isPersistingOrder = false);
      }
    }
  }
}
