import 'package:flutter/material.dart';

import 'router/app_router.dart';

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
    );
  }
}
