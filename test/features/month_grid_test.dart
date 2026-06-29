// test/features/month_grid_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dianiels_calendar/models/calendar_event.dart';
import 'package:dianiels_calendar/models/enums.dart';
import 'package:dianiels_calendar/utils/date_utils.dart';
import 'package:dianiels_calendar/features/month/widgets/month_grid.dart';

void main() {
  testWidgets('MonthGrid renders weekday header Mon', (tester) async {
    final togetherEvent = CalendarEvent(
      id: 'e1',
      title: 'Date night',
      date: DateTime(2026, 7, 4),
      owner: EventOwner.together,
      createdBy: 'uid1',
    );
    final eventsByDay = {
      dayKey(DateTime(2026, 7, 4)): [togetherEvent],
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          // MonthGrid is self-sizing and non-scrolling; the surrounding scroll
          // surface is the caller's responsibility (here a test ListView, in the
          // app the MonthViewScreen ListView).
          body: ListView(
            children: [
              MonthGrid(
                month: DateTime(2026, 7, 1),
                eventsByDay: eventsByDay,
                onDayTap: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    // Weekday header present
    expect(find.text('Mon'), findsOneWidget);

    // Day 4 cell rendered
    expect(find.text('4'), findsOneWidget);

    // Together event shows a heart
    expect(find.text('❤️'), findsWidgets);
  });
}
