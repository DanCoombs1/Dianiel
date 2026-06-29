# Broad Review Fixes — Implementation Report

Date: 2026-06-29

## flutter test (full suite)

```
00:03 +33: All tests passed!
```

33 tests pass (up from 32 before these fixes).

## flutter analyze

```
Analyzing Dianiel...
No issues found! (ran in 1.3s)
```

---

## Fix notes

### FIX 1 — Weekly recurrence DST drift (real bug)
- **File changed:** `lib/utils/recurrence_expander.dart`
- Changed the weekly `_step` closure from `d.add(const Duration(days: 7))` to `DateTime(d.year, d.month, d.day + 7)`. The old Duration-based arithmetic could shift wall-clock time across a DST boundary; the new constructor form always produces midnight on the correct calendar day.
- **Regression test added:** `test/utils/recurrence_expander_test.dart` — "weekly crossing UK spring-forward (2026) stays at hour 0, exactly 7 calendar days apart". Base date 2026-03-22, range to 2026-04-12, crossing the 2026 UK clock-forward on 2026-03-29. Asserts four occurrences at [Mar 22, Mar 29, Apr 5, Apr 12] all with `hour == 0`.

### FIX 2 — Move `ownerColor` to theme layer
- **New file:** `lib/theme/owner_color.dart` — contains `ownerColor(EventOwner o)` importing `EventOwner` from models and `AppColors` from the theme layer.
- **Updated:** `lib/features/month/widgets/day_cell.dart` — removed local `ownerColor` definition and the now-unused `enums.dart` import; imports `ownerColor` from `lib/theme/owner_color.dart`.
- **Updated:** `lib/features/day/day_agenda_screen.dart` — replaced `import '../month/widgets/day_cell.dart' show ownerColor` with `import '../../theme/owner_color.dart'`. Behavior is identical.

### FIX 3 — Strengthen three weak tests

#### month_view_test.dart
- Added `intl` import and a month-title assertion: computes `DateFormat('MMMM yyyy').format(DateTime(now.year, now.month))` and asserts `find.text(expectedTitle)` findsOneWidget — verifying the `MonthPhotoHeader` renders the correct month string.

#### day_agenda_test.dart
- Fake repo now returns TWO events: 'Cinema' (together, on the requested day) and 'OtherDay' (diana, on the next day).
- Added assertions: `find.textContaining('OtherDay')` findsNothing (proves day-filtering), and `find.textContaining('❤️')` findsOneWidget (proves together-convention heart rendering).

#### calendar_event_test.dart
- Round-trip test now asserts all fields survive: `back.date`, `back.allDay`, `back.location`, `back.recurrence`, and `back.isBigDate` in addition to the existing title/owner/reminder/startTime checks.

### FIX 4 — Theme test
- **File changed:** `test/theme/app_theme_test.dart`
- Replaced vacuous `expect(theme.colorScheme.primary, isNotNull)` with `expect(theme.scaffoldBackgroundColor, AppColors.background)` — a real assertion that verifies the scaffold background is wired to the design token. The `useMaterial3` check is retained.
