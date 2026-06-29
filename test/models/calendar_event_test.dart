import 'package:flutter_test/flutter_test.dart';
import 'package:dianiels_calendar/models/calendar_event.dart';
import 'package:dianiels_calendar/models/enums.dart';

void main() {
  test('round-trips through Firestore map', () {
    final e = CalendarEvent(
      id: 'e1', title: 'Date night',
      date: DateTime(2026, 7, 4), startTime: '18:30', allDay: false,
      location: 'The Ivy', owner: EventOwner.together, notes: 'wear pink',
      reminder: ReminderOption.oneHour, recurrence: Recurrence.none,
      isBigDate: false, createdBy: 'uid1',
    );
    final map = e.toFirestore();
    final back = CalendarEvent.fromFirestore('e1', map);
    expect(back.title, 'Date night');
    expect(back.owner, EventOwner.together);
    expect(back.reminder, ReminderOption.oneHour);
    expect(back.startTime, '18:30');
    expect(back.date, DateTime(2026, 7, 4));
    expect(back.allDay, false);
    expect(back.location, 'The Ivy');
    expect(back.recurrence, Recurrence.none);
    expect(back.isBigDate, false);
  });

  test('ReminderOption lead times', () {
    expect(ReminderOption.none.leadTime, isNull);
    expect(ReminderOption.oneHour.leadTime, const Duration(hours: 1));
    expect(ReminderOption.oneDay.leadTime, const Duration(days: 1));
  });

  test('together owner reports isTogether', () {
    expect(EventOwner.together.isTogether, isTrue);
    expect(EventOwner.diana.isTogether, isFalse);
  });
}
