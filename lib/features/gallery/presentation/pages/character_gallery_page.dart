import 'package:flutter/material.dart';
import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/layout/bottom_action_slot.dart';
import 'package:mycharacterlist/app/widgets/layout/screen_scaffold.dart';
import 'package:mycharacterlist/features/gallery/presentation/widgets/character_gallery_picker.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/Plus_button.dart';

class CharacterGalleryPage extends StatefulWidget {
  const CharacterGalleryPage({
    super.key,
    required this.characterId,
  });

  final String characterId;

  @override
  State<CharacterGalleryPage> createState() => _CharacterGalleryPageState();
}

class _CharacterGalleryPageState extends State<CharacterGalleryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    const Text(
                      'Character name',
                      style: TextStyle(
                        fontSize: 32,
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
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: const CharacterGalleryPicker(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
