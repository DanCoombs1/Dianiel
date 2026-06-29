import 'package:flutter_test/flutter_test.dart';
import 'package:dianiels_calendar/models/calendar_event.dart';
import 'package:dianiels_calendar/models/enums.dart';
import 'package:dianiels_calendar/utils/recurrence_expander.dart';

CalendarEvent ev(DateTime d, Recurrence r) => CalendarEvent(
  id: 'x', title: 't', date: d, owner: EventOwner.diana,
  recurrence: r, createdBy: 'u');

void main() {
  test('non-recurring event included only if within range', () {
    final base = [ev(DateTime(2026, 7, 10), Recurrence.none)];
    expect(expandEvents(base, DateTime(2026, 7, 1), DateTime(2026, 7, 31)).length, 1);
    expect(expandEvents(base, DateTime(2026, 8, 1), DateTime(2026, 8, 31)), isEmpty);
  });

  test('yearly birthday recurs in a future year', () {
    final base = [ev(DateTime(2000, 7, 15), Recurrence.yearly)];
    final out = expandEvents(base, DateTime(2026, 7, 1), DateTime(2026, 7, 31));
    expect(out.length, 1);
    expect(out.first.date, DateTime(2026, 7, 15));
  });

  test('weekly recurs every 7 days within range', () {
    final base = [ev(DateTime(2026, 7, 1), Recurrence.weekly)];
    final out = expandEvents(base, DateTime(2026, 7, 1), DateTime(2026, 7, 31));
    expect(out.map((e) => e.date.day), [1, 8, 15, 22, 29]);
  });

  test('monthly recurs same day-of-month', () {
    final base = [ev(DateTime(2026, 1, 5), Recurrence.monthly)];
    final out = expandEvents(base, DateTime(2026, 7, 1), DateTime(2026, 9, 30));
    expect(out.map((e) => '${e.date.year}-${e.date.month}-${e.date.day}'),
        ['2026-7-5', '2026-8-5', '2026-9-5']);
  });

  test('monthly on the 31st skips short months (no spillover)', () {
    final base = [ev(DateTime(2026, 1, 31), Recurrence.monthly)];
    final out = expandEvents(base, DateTime(2026, 1, 1), DateTime(2026, 4, 30));
    // Jan and Mar have 31 days; Feb (28) and Apr (30) must be skipped, not spilled.
    expect(out.map((e) => '${e.date.month}-${e.date.day}'), ['1-31', '3-31']);
  });

  test('yearly on Feb 29 only appears in leap years', () {
    final base = [ev(DateTime(2000, 2, 29), Recurrence.yearly)];
    final nonLeap = expandEvents(base, DateTime(2026, 1, 1), DateTime(2026, 12, 31));
    expect(nonLeap, isEmpty);
    final leap = expandEvents(base, DateTime(2028, 1, 1), DateTime(2028, 12, 31));
    expect(leap.single.date, DateTime(2028, 2, 29));
  });

  test('weekly crossing UK spring-forward (2026) stays at hour 0, exactly 7 calendar days apart', () {
    // UK clocks go forward last Sunday of March 2026 = 29 Mar 2026.
    // Base date Mar 22, range to Apr 12 — crosses the DST boundary.
    final base = [ev(DateTime(2026, 3, 22), Recurrence.weekly)];
    final out = expandEvents(base, DateTime(2026, 3, 22), DateTime(2026, 4, 12));
    final expectedDates = [
      DateTime(2026, 3, 22),
      DateTime(2026, 3, 29),
      DateTime(2026, 4, 5),
      DateTime(2026, 4, 12),
    ];
    expect(out.length, 4);
    for (var i = 0; i < out.length; i++) {
      expect(out[i].date, expectedDates[i],
          reason: 'occurrence $i should be ${expectedDates[i]}');
      expect(out[i].date.hour, 0,
          reason: 'occurrence $i should have hour == 0 (no DST drift)');
    }
  });
}
