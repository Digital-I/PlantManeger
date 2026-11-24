import 'package:flutter/material.dart';

/// Единая тема приложения на базе Material 3.
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
  );
}
