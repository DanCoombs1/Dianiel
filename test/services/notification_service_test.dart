import 'package:flutter_test/flutter_test.dart';
import 'package:dianiels_calendar/models/calendar_event.dart';
import 'package:dianiels_calendar/models/enums.dart';
import 'package:dianiels_calendar/services/notification_service.dart';

void main() {
  test('reminderTime subtracts lead time from start', () {
    final e = CalendarEvent(id: 'a', title: 't', date: DateTime(2026, 7, 4),
        startTime: '18:00', allDay: false, owner: EventOwner.diana,
        reminder: ReminderOption.oneHour, createdBy: 'u');
    expect(reminderTime(e), DateTime(2026, 7, 4, 17, 0));
  });

  test('reminderTime is null when reminder is none', () {
    final e = CalendarEvent(id: 'a', title: 't', date: DateTime(2026, 7, 4),
        owner: EventOwner.diana, reminder: ReminderOption.none, createdBy: 'u');
    expect(reminderTime(e), isNull);
  });

  test('notificationIdFor is stable and positive', () {
    expect(notificationIdFor('abc'), notificationIdFor('abc'));
    expect(notificationIdFor('abc'), greaterThanOrEqualTo(0));
  });
}
