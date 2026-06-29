# Task 1 Report: Create the Flutter project and baby-pink theme

**Date:** 2026-06-29  
**Status:** DONE

---

## Files Created / Modified

### Created by `flutter create`
- `pubspec.yaml`
- `lib/main.dart` (scaffold default — will be replaced in Task 2)
- `analysis_options.yaml`
- `README.md`
- `dianiels_calendar.iml`
- `.gitignore`
- `test/widget_test.dart`
- `ios/` (full iOS project scaffold — Runner.xcodeproj, Runner.xcworkspace, Podfile, etc.)
- `.idea/` (IDE config files)

### Created by dependency steps
- `pubspec.lock` (auto-generated)

### Created manually (theme implementation)
- `lib/theme/app_colors.dart`
- `lib/theme/app_theme.dart`

### Created (TDD test)
- `test/theme/app_theme_test.dart`

### Created (this report)
- `docs/superpowers/reports/task-1-report.md`

---

## Dependencies Added

**Runtime:**
- `flutter_riverpod: ^3.3.2`
- `firebase_core: ^4.11.0`
- `firebase_auth: ^6.5.4`
- `cloud_firestore: ^6.6.0`
- `firebase_storage: ^13.4.3`
- `firebase_messaging: ^16.4.1`
- `sign_in_with_apple: ^7.0.1`
- `flutter_local_notifications: ^22.0.1`
- `timezone: ^0.11.1`
- `image_picker: ^1.2.2`
- `intl: ^0.20.3`

**Dev:**
- `fake_cloud_firestore: ^4.1.1`
- `mocktail: ^1.0.5`

---

## Test Command and Output

**Command:** `flutter test test/theme/app_theme_test.dart`

**Output:**
```
Resolving dependencies...
Got dependencies!
00:03 +0: loading /Users/danbc/repos/Dianiel/test/theme/app_theme_test.dart
00:03 +1: app theme uses baby pink seed and Material 3
00:03 +2: owner colors are distinct
00:03 +2: All tests passed!
```

**Result:** 2/2 tests passed.

### Failing-first confirmation
Before implementing `lib/theme/app_colors.dart` and `lib/theme/app_theme.dart`, the test was run and failed with:
```
Error when reading 'lib/theme/app_theme.dart': No such file or directory
Error when reading 'lib/theme/app_colors.dart': No such file or directory
Method not found: 'buildAppTheme'
Undefined name 'AppColors'
```
This confirms the TDD red→green cycle was correctly followed.

---

## Concerns

1. **Newer package versions available:** `flutter pub outdated` shows 15 packages with newer versions that are incompatible with current constraint ranges. This is normal for a fresh project and does not affect functionality. The pinned versions work correctly.

2. **`sign_in_with_apple` version 7.0.1 used (8.1.0 available):** The newer version was flagged as incompatible with current constraints. Version 7.0.1 is stable and sufficient for Task 1. This may need revisiting before Task 3 (auth implementation).

3. **Step 7 (git commit) was intentionally skipped** per the task instruction: "DO NOT run ANY git command." All changes are left unstaged in the working tree for the human to manage.

4. **`docs/` directory preserved:** Confirmed — the `flutter create` command output does not show any docs/ files being modified or deleted. The existing `docs/` directory is intact.
