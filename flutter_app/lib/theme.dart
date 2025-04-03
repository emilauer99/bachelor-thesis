import 'package:flutter/material.dart';

final theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),

  textTheme: TextTheme().copyWith(
    titleLarge: const TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
    ),
    titleSmall: const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: const TextStyle(
      fontSize: 22.0,
    ),
    bodyMedium: const TextStyle(
      fontSize: 18.0,
    ),
    bodySmall: const TextStyle(
      fontSize: 14.0,
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: Colors.transparent,
    side: BorderSide.none,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  )

);