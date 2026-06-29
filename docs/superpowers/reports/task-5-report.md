# Task 5 Report: Recurrence Expander

## Files Touched

- Created: `lib/utils/recurrence_expander.dart`
- Created: `test/utils/recurrence_expander_test.dart`

## TDD Summary

1. Wrote `test/utils/recurrence_expander_test.dart` first (4 tests). Confirmed red: compilation failed with "No such file or directory" for the import and "Method not found: expandEvents" for all call sites.
2. Implemented `lib/utils/recurrence_expander.dart` with `expandEvents`, `_step`, and `_stepMonths`.
3. Fixed a lint hint (curly_braces_in_flow_control_structures) on the `while (d.isBefore(start))` line — added braces.
4. All 4 tests green; `flutter analyze` reports no issues.

## Test Output

```
00:00 +1: non-recurring event included only if within range
00:00 +2: yearly birthday recurs in a future year
00:00 +3: weekly recurs every 7 days within range
00:00 +4: monthly recurs same day-of-month
00:00 +4: All tests passed!
```

## Analyze Output

```
No issues found! (ran in 0.9s)
```

## Implementation Notes

- `expandEvents` dispatches on `e.recurrence` using Dart exhaustive switch (no default needed — compiler enforces all enum arms).
- `_step` (weekly) advances from the event's base date into range, then emits every 7 days.
- `_stepMonths` (monthly/yearly) walks calendar months from `rangeStart`; `monthStep=1` for monthly, `12` for yearly. The `occ.month == cursor.month` guard silently skips impossible days (e.g., Jan 31 in a month with 30 days) rather than spilling into the next month.
- Results sorted ascending by `startsAt` before returning.
- occurrences keep the original `id` via `copyWith(date: occ)` — consistent with spec.

## Concerns

- None. Implementation matches spec exactly. No Firebase dependencies; pure Dart.
- The 15 packages-have-newer-versions warning is a pre-existing dependency constraint issue unrelated to this task.
