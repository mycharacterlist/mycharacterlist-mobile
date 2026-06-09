import 'package:flutter/material.dart';

class AddCharacterDialog extends StatefulWidget {

  final Function(
      String title,
      String subtitle,
      )
  onCreate;

  const AddCharacterDialog({
    super.key,

    required this.onCreate,
  });

  @override
  State<AddCharacterDialog>
  createState() =>
      _AddCharacterDialogState();
}

class _AddCharacterDialogState extends State<AddCharacterDialog> {

  final TextEditingController
  titleController = TextEditingController();

  final TextEditingController
  subtitleController = TextEditingController();

  @override
  Widget build(
      BuildContext context,
      ) {

    return AlertDialog(
      title:
      const Text('Create character card'),

      content:
      Column(
        mainAxisSize: MainAxisSize.min,

        children: [

          TextField(
            controller: titleController,

            decoration:
            const InputDecoration(
              labelText: 'Main text',
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: subtitleController,

            decoration:
            const InputDecoration(
              labelText: 'Side text',
            ),
          ),
        ],
      ),

      actions: [

        TextButton(
          onPressed: () {

            Navigator.pop(
              context,
            );
          },

          child:
          const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: () {

            if (
            titleController.text
                .trim()
                .isEmpty
            ) {

              return;
            }

            widget.onCreate(
              titleController.text,
              subtitleController.text,
            );

            Navigator.pop(
              context,
            );
          },

          child:
          const Text('Create'),
        ),
      ],
    );
  }
}