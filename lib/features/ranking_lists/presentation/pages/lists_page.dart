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

      onCreate: () {

        if (controller.text.isNotEmpty) {

          setState(() {

            lists.add({

              'title': controller.text,

              'color': Color.fromARGB(255,

                Random().nextInt(256),
                Random().nextInt(256),
                Random().nextInt(256),
              ),
            });
          });

          controller.clear();

          Navigator.pop(
            context,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Lists',

        backgroundColor:
        const Color(0xFF0E2432),

        backButtonColor:
        const Color(0xFFB60894),

        titleColor:
        const Color(0xFFB60894),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/ListsPage_bg.png',
            ),
            fit: BoxFit.cover,
          ),
        ),

        child: Column(
          children: [

            const SizedBox(
              height: 20,
            ),

            Expanded(
              child: ListView(
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
                              const Color(0xFF3D4789),
                              list['color'],
                            ],

                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),

                          borderRadius:
                          BorderRadius.circular(20,),

                          boxShadow: [
                            BoxShadow(
                              color:
                              Colors.black.withOpacity(0.35,),
                              blurRadius: 15,
                              offset:
                              const Offset(0, -5,),
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
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.only(
                bottom: 40,
              ),

              child: CreateNewButton(
                text: 'Create new',

                onPressed:
                showCreateDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}