// test/features/countdown_strip_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dianiels_calendar/models/calendar_event.dart';
import 'package:dianiels_calendar/models/enums.dart';
import 'package:dianiels_calendar/features/countdown/countdown_strip.dart';

void main() {
  test('upcomingBigDates returns only big dates, soonest first', () {
    final all = [
      CalendarEvent(
          id: 'a',
          title: 'Anniversary',
          date: DateTime(2000, 7, 20),
          owner: EventOwner.together,
          recurrence: Recurrence.yearly,
          isBigDate: true,
          createdBy: 'u'),
      CalendarEvent(
          id: 'b',
          title: 'Random',
          date: DateTime(2026, 7, 5),
          owner: EventOwner.dan,
          isBigDate: false,
          createdBy: 'u'),
      CalendarEvent(
          id: 'c',
          title: 'Trip',
          date: DateTime(2026, 7, 10),
          owner: EventOwner.together,
          isBigDate: true,
          createdBy: 'u'),
    ];
    final out = upcomingBigDates(all, DateTime(2026, 7, 1));
    expect(out.map((e) => e.title), ['Trip', 'Anniversary']);
  });
}
