import 'package:flutter/material.dart';

class CreateListDialog {

  static void show({
    required BuildContext context,

    required TextEditingController controller,

    required VoidCallback onCreate,
  }) {

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Create list',
          ),

          content: TextField(
            controller: controller,

            decoration:
            const InputDecoration(
              hintText:
              'Enter list name',
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },

              child: const Text(
                'Cancel',
              ),
            ),

            TextButton(
              onPressed: onCreate,

              child: const Text(
                'Create',
              ),
            ),
          ],
        );
      },
    );
  }
}