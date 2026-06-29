// test/theme/app_theme_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dianiels_calendar/theme/app_theme.dart';
import 'package:dianiels_calendar/theme/app_colors.dart';

void main() {
  test('app theme uses baby pink seed and Material 3', () {
    final theme = buildAppTheme();
    expect(theme.useMaterial3, isTrue);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
  });

  test('owner colors are distinct', () {
    expect(AppColors.diana, isNot(AppColors.dan));
    expect(AppColors.together, isNot(AppColors.diana));
  });
}
