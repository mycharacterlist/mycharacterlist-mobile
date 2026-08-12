import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/utils/system_view_padding.dart';
import 'package:mycharacterlist/features/patches/presentation/widgets/patch_notes_manager.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';

class RankingListPatchesPage extends ConsumerStatefulWidget {
  const RankingListPatchesPage({
    super.key,
    required this.listId,
  });

  final String listId;

  @override
  ConsumerState<RankingListPatchesPage> createState() =>
      _RankingListPatchesPageState();
}

class _RankingListPatchesPageState
    extends ConsumerState<RankingListPatchesPage> {
  final GlobalKey<PatchNotesManagerState> _patchNotesManagerKey =
      GlobalKey<PatchNotesManagerState>();

  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    final rankingList = ref.watch(rankingListByIdProvider(widget.listId));
    final listName = rankingList?.name ?? 'List';

    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: CustomAppBar(
        title: 'Patch notes',
        backgroundColor: const Color(0xFF3F372C),
        titleColor: Colors.black,
        backButtonColor: Colors.black,

        actionWidget: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
            icon: Icon(
              _isEditMode ? Icons.check : Icons.edit_outlined,
              color: Colors.black,
            ),
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

          SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    listName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontFamily: 'DoublePicaREG',
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: SystemViewPadding.bottomOf(context) + 12,
                    ),
                    child: PatchNotesManager(
                      key: _patchNotesManagerKey,
                      listId: widget.listId,
                      isEditMode: _isEditMode,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
