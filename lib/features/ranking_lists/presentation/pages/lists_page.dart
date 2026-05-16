import 'package:flutter/material.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ListsPage_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
