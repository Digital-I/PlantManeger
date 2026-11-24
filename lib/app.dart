import 'package:flutter/material.dart';
import 'package:plantmanager/core/theme.dart';
import 'package:plantmanager/router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Plant Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
      );
}
