import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';

import 'package:mycharacterlist/features/patches/presentation/widgets/patch_notes_manager.dart';

class RankingListPatchesPage
    extends ConsumerStatefulWidget {

  const RankingListPatchesPage({
    super.key,
    required this.listId,
  });

  final String listId;

  @override
  ConsumerState<RankingListPatchesPage>
  createState() =>
      _RankingListPatchesPageState();
}

class _RankingListPatchesPageState
    extends ConsumerState<
        RankingListPatchesPage> {

  final GlobalKey<PatchNotesManagerState>
  _patchNotesKey =
  GlobalKey<PatchNotesManagerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: CustomAppBar(
        title: 'Patch notes',
        backgroundColor: const Color(0xFF3F372C),
        titleColor: Colors.black,
        backButtonColor: Colors.black,

        actionWidget: IconButton(
          onPressed: () {
            _patchNotesKey
                .currentState
                ?.toggleAddPatch();
          },

          icon: const Icon(
            Icons.edit_outlined,
            color: Colors.black,
            size: 30,
          ),
        ),
      ),

      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/images/Patches_bg.jpg',

              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
              ),

              child: Column(
                children: [

                  const SizedBox(
                    height: 10,
                  ),

                  const Text(
                    'Main list Patches',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      color: Colors.white,
                      fontFamily: 'DoublePicaREG',
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Expanded(
                    child:
                    PatchNotesManager(
                      key: _patchNotesKey,
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
