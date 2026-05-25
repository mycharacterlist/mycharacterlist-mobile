import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CreateListDialog {

  static void show({
    required BuildContext context,
    required TextEditingController controller,
    required Function(Color) onCreate,
  }) {

    Color selectedColor = const Color(0xFF768AFD);

    showDialog(
      context: context,

      builder: (context) {

        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {

            return AlertDialog(
              title: const Text('Create list',),

              content:
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    TextField(
                      controller: controller,

                      decoration:
                      const InputDecoration(
                        hintText: 'Enter list name',
                      ),
                    ),

                    const SizedBox(height: 20,),

                    const Align(
                      alignment: Alignment.centerLeft,

                      child: Text('Choose color',),
                    ),

                    const SizedBox(height: 10,),

                    ColorPicker(
                      pickerColor:
                      selectedColor,

                      onColorChanged:
                          (color) {

                        setDialogState(
                              () {

                            selectedColor =
                                color;
                          },
                        );
                      },

                      enableAlpha: false,

                      displayThumbColor: true,

                      portraitOnly: true,

                      showLabel: false,

                      pickerAreaHeightPercent: 0.8,
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
                  onPressed: () {

                    onCreate(
                      selectedColor,
                    );
                  },

                  child: const Text('Create',),
                ),
              ],
            );
          },
        );
      },
    );
  }
}