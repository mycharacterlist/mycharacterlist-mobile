import 'package:flutter/material.dart';
import '../../../../app/widgets/app_appbar.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'My Lists',
          backgroundColor: const Color(0xFF0E2432),
          backButtonColor: const Color(0xFFB60894),
          titleColor: const Color(0xFFB60894),
      ),
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
