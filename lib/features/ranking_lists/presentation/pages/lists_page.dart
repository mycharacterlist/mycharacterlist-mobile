import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../app/widgets/app_appbar.dart';
import '../widgets/CreateNew_button.dart';
import '../widgets/create_list_dialog.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() =>
      _ListsPageState();
}

class _ListsPageState
    extends State<ListsPage> {

  final List<Map<String, dynamic>>
  lists = [];

  final TextEditingController controller =
  TextEditingController();

  void showCreateDialog() {

    CreateListDialog.show(
      context: context,

      controller: controller,

      onCreate:
          (selectedColor) {

        if (controller.text.isNotEmpty) {

          setState(() {

            lists.add({

              'title': controller.text,

              'color': selectedColor,
            });
          });

          controller.clear();

          Navigator.pop(context,);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      resizeToAvoidBottomInset: false,

      appBar: CustomAppBar(
        title: 'My Lists',

        backgroundColor:
        const Color(0xFF0E2432),

        backButtonColor:
        const Color(0xFFB60894),

        titleColor:
        const Color(0xFFB60894),
      ),

      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/images/ListsPage_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120,),

              child: ListView(
                padding: const EdgeInsets.only(top: 20,),

                children: [

                  ...lists.map(
                        (list) => Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),

                      child: Container(
                        height: 70,

                        decoration:
                        BoxDecoration(

                          gradient:
                          LinearGradient(
                            colors: [
                              const Color(0xFF3D4789,),

                              list['color'],
                            ],

                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),

                          borderRadius:
                          BorderRadius.circular(20,),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35,),
                              blurRadius: 15,
                              offset: const Offset(0, -5,),
                            ),
                          ],
                        ),

                        child:
                        ElevatedButton(
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),

                          onPressed: () {},

                          child: Text(
                            list['title'],

                            style:
                            const TextStyle(
                              fontSize: 24,
                              fontFamily: 'JPAnimeFont',
                              color: Color(0xFFBEB53E,),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 40,

            child: Center(
              child: CreateNewButton(
                text: 'Create new',

                onPressed:
                showCreateDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }
}