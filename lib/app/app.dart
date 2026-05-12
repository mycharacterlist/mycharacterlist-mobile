import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/router/app_router.dart';
// import 'package:mycharacterlist/development/router/development_router.dart';

class MyCharacterListApp extends StatelessWidget {
  const MyCharacterListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MyCharacterList',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
      // routerConfig: developmentRouter,
    );
  }
}
