import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/features/patches/presentation/widgets/patch_notes_manager.dart';

class RankingListPatchesPage extends ConsumerWidget {
  const RankingListPatchesPage({
    super.key,
    required this.listId,
  });

  final String listId;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: CustomAppBar(
        title: 'Patch notes',
        backgroundColor: const Color(0xFF3F372C),
        titleColor: Colors.black,
        backButtonColor: Colors.black,

        actionWidget: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.add,
            color: Colors.black,
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

                const Text(
                  'Main list Patches',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontFamily: 'DoublePicaREG',
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: PatchNotesManager(),
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