import 'package:flutter/material.dart';

import 'package:mycharacterlist/features/patches/presentation/widgets/patch_note_card.dart';
import 'package:mycharacterlist/features/patches/presentation/widgets/patch_note_form.dart';

class PatchNotesManager extends StatefulWidget {
  const PatchNotesManager({
    super.key,
  });

  @override
  State<PatchNotesManager> createState() =>
      PatchNotesManagerState();
}

class PatchNotesManagerState extends State<PatchNotesManager> {

  final TextEditingController
  _versionController = TextEditingController();

  final TextEditingController
  _releaseDateController = TextEditingController();

  final ScrollController
  _scrollController = ScrollController();

  final List<PatchNoteData> _patches =
  [];

  bool _showAddPatch = false;

  void toggleAddPatch() {
    setState(() {
      _showAddPatch =
      !_showAddPatch;
    });
  }

  void addPatch() {
    final String version = _versionController.text.trim();

    final String releaseDate = _releaseDateController.text.trim();

    if (version.isEmpty ||
        releaseDate.isEmpty) {
      return;
    }

    setState(() {
      _patches.add(
        PatchNoteData(
          version: version,
          releaseDate: releaseDate,
        ),
      );

      _versionController.clear();

      _releaseDateController.clear();

      _showAddPatch = false;
    });
  }

  void closeForm() {
    setState(() {
      _showAddPatch = false;
    });
  }

  @override
  void dispose() {
    _versionController.dispose();

    _releaseDateController.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 30,

          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 5,
            radius: const Radius.circular(10),

            child: ListView.builder(
              controller:
              _scrollController,

              padding:
              const EdgeInsets.only(
                top: 5,
                right: 8,
              ),

              itemCount: _patches.length,

              itemBuilder:
                  (context, index) {

                final patch = _patches[index];

                return PatchNoteCard(
                  number: index + 1,
                  version: patch.version,
                  releaseDate: patch.releaseDate,

                  onPressed: () {},
                );
              },
            ),
          ),
        ),

        if (_showAddPatch)
          Positioned(
            top: 5,
            left: 0,
            right: 0,

            child: PatchNoteForm(
              versionController: _versionController,
              releaseDateController: _releaseDateController,
              onAdd: addPatch,
            ),
          ),
      ],
    );
  }
}

class PatchNoteData {
  const PatchNoteData({
    required this.version,
    required this.releaseDate,
  });

  final String version;
  final String releaseDate;
}