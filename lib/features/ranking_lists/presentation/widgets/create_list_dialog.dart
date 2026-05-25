import 'package:flutter/material.dart';

class CreateListDialog {

  static void show({
    required BuildContext context,
    required TextEditingController controller,
    required Function(Color) onCreate,
  }) {

    final colors = [

      const Color(0xFF768AFD),
      const Color(0xFFB60894),
      const Color(0xFF3D4789),
      const Color(0xFF2F013B),
      Colors.green,
      Colors.red,
      Colors.amber
    ];

    Color selectedColor = colors.first;

    showDialog(
      context: context,

      builder: (context) {

        return StatefulBuilder(
          builder: (context, setDialogState,
              )
          {

            return AlertDialog(
              title: const Text('Create list',),

              content:
              SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,

                  children: [

                    TextField(
                      controller: controller,

                      decoration:
                      const InputDecoration(
                        hintText:
                        'Enter list name',
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Align(
                      alignment:
                      Alignment.centerLeft,

                      child: Text(
                        'Choose color',
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    ...colors.map(
                          (color) {

                        return Row(
                          children: [

                            Checkbox(
                              value:
                              selectedColor == color,

                              activeColor: color,

                              onChanged:
                                  (_) {

                                setDialogState(
                                      () {

                                    selectedColor = color;
                                  },
                                );
                              },
                            ),

                            Container(
                              width: 30,
                              height: 30,

                              decoration:
                              BoxDecoration(color: color,
                                borderRadius: BorderRadius.circular(8,),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
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