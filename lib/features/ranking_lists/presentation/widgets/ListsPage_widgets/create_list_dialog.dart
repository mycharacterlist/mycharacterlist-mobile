import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CreateListDialog {
  static void show({
    required BuildContext context,
    required TextEditingController controller,
    required Future<void> Function(Color) onCreate,
    Color initialColor = const Color(0xFF768AFD),
    String title = 'Create list',
    String submitLabel = 'Create',
    Future<void> Function()? onDelete,
  }) {
    Color selectedColor = initialColor;
    String? nameErrorText;

    showDialog(
      context: context,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    TextField(
                      controller: controller,
                      onChanged: (_) {
                        if (nameErrorText == null) {
                          return;
                        }

                        setDialogState(() {
                          nameErrorText = null;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter list name',
                        errorText: nameErrorText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Choose color'),
                    ),
                    const SizedBox(height: 10),
                    ColorPicker(
                      pickerColor: selectedColor,
                      onColorChanged: (color) {
                        setDialogState(() {
                          selectedColor = color;
                        });
                      },
                      enableAlpha: false,
                      displayThumbColor: true,
                      portraitOnly: true,
                      labelTypes: const [],
                      pickerAreaHeightPercent: 0.8,
                    ),
                  ],
                ),
              ),

              actions: [
                if (onDelete != null)
                  TextButton(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),

                TextButton(
                  onPressed: () {
                    controller.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),

                TextButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) {
                      setDialogState(() {
                        nameErrorText = 'Enter list name';
                      });

                      return;
                    }

                    await onCreate(selectedColor);
                  },

                  child: Text(submitLabel),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
