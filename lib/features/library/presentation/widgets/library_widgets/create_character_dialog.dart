import 'package:flutter/material.dart';

class CreateCharacterDialog {

  static void show({
    required BuildContext context,

    required TextEditingController
    mainController,

    required TextEditingController
    sideController,

    required VoidCallback onCreate,
  }) {

    showDialog(
      context: context,

      builder: (context) {

        return AlertDialog(
          title: const Text('Create card',),

          content:
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                TextField(
                  controller: mainController,

                  decoration:
                  const InputDecoration(hintText: 'Main text',),
                ),

                const SizedBox(height: 20,),

                TextField(
                  controller: sideController,

                  decoration:
                  const InputDecoration(
                    hintText:
                    'Side text',
                  ),
                ),
              ],
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context,);
              },

              child: const Text('Cancel',),
            ),

            TextButton(
              onPressed: onCreate,

              child: const Text('Create',),
            ),
          ],
        );
      },
    );
  }
}