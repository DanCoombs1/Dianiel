// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.babyPink,
    brightness: Brightness.light,
  ).copyWith(surface: AppColors.background);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.babyPink,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
  );
}
